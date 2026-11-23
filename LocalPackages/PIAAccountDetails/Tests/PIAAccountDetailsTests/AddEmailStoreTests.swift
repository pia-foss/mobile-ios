//
//  AddEmailStoreTests.swift
//  PIAAccountDetailsTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import CoreArchitecture
import Foundation
import PIALibrary
import Testing

@testable import PIAAccountDetails

@MainActor
struct AddEmailStoreTests {

    private let spy = AddEmailDependencySpy()

    private func makeStore(
        state: AddEmail.State = AddEmail.State()
    ) -> TestStore<AddEmail.State, AddEmail.Action> {
        TestStore(
            initial: state,
            reduce: AddEmail.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    // MARK: Validation

    @Test(
        "An invalid email is flagged and not sent",
        arguments: [
            ("", Validator.EmailValidationError.emailIsEmpty),
            ("   ", .emailIsEmpty),
            ("foo@", .emailIsInvalid)
        ])
    func invalidEmail(email: String, error: Validator.EmailValidationError) async {
        let sut = makeStore(state: .init(email: email, hasConsented: true))

        sut.send(.submitTapped)
        await sut.finish()

        #expect(sut.state.emailError == error)
        #expect(!sut.state.isSubmitting)
        #expect(spy.updatedEmails.isEmpty)
    }

    @Test("Editing the email clears its error")
    func editingClearsError() async {
        let sut = makeStore(state: .init(email: "foo@", emailError: .emailIsInvalid))

        sut.send(.emailChanged("foo@example.com"))
        await sut.finish()

        #expect(sut.state.email == "foo@example.com")
        #expect(sut.state.emailError == nil)
    }

    // MARK: Consent

    @Test("The first submit asks for consent before sending")
    func firstSubmitAsksForConsent() async {
        let sut = makeStore(state: .init(email: "user@example.com"))

        sut.send(.submitTapped)
        await sut.finish()

        #expect(sut.state.alert == .consent)
        #expect(!sut.state.isSubmitting)
        #expect(spy.updatedEmails.isEmpty)
    }

    @Test("Agreeing sends the email and remembers the consent")
    func consentSends() async throws {
        let sut = makeStore(state: .init(email: "user@example.com", alert: .consent))

        sut.send(.consentGiven)
        #expect(sut.state.hasConsented)
        #expect(sut.state.alert == nil)
        #expect(sut.state.isSubmitting)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.updatedEmails == ["user@example.com"])
    }

    @Test("Declining consent sends nothing")
    func decliningConsent() async {
        let sut = makeStore(state: .init(email: "user@example.com", alert: .consent))

        sut.send(.alertDismissed)
        await sut.finish()

        #expect(sut.state.alert == nil)
        #expect(!sut.state.hasConsented)
        #expect(spy.updatedEmails.isEmpty)
    }

    // MARK: Update

    @Test("A successful update shows the credentials for the trimmed email")
    func updateSucceeds() async throws {
        let sut = makeStore(state: .init(email: " user@example.com\n", hasConsented: true))

        sut.send(.submitTapped)
        let action = try #require(await sut.receive())
        await sut.finish()

        #expect(action == .updateSucceeded(email: "user@example.com", credentials: .stub))
        #expect(spy.updatedEmails == ["user@example.com"])
        #expect(!sut.state.isSubmitting)
        #expect(sut.state.step == .done(email: "user@example.com", credentials: .stub))
    }

    @Test("A failed update clears the email and explains")
    func updateFails() async throws {
        spy.updateResult = nil
        let sut = makeStore(state: .init(email: "user@example.com", hasConsented: true))

        sut.send(.submitTapped)
        #expect(try #require(await sut.receive()) == .updateFailed)
        await sut.finish()

        #expect(!sut.state.isSubmitting)
        #expect(sut.state.email == "")
        #expect(sut.state.alert == .updateFailed)
        #expect(sut.state.step == .form)
    }

    @Test("Submits while one is in flight are ignored")
    func submitsWhileSubmittingAreIgnored() async throws {
        let sut = makeStore(state: .init(email: "user@example.com", hasConsented: true))

        sut.send(.submitTapped)
        sut.send(.submitTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.updatedEmails.count == 1)
    }

    // MARK: Sign in with Apple

    @Test("The email Apple shares is remembered and submitted")
    func appleIDSharesEmail() async throws {
        let sut = makeStore()

        sut.send(.appleIDAuthorized(email: "abc@privaterelay.appleid.com"))
        #expect(try #require(await sut.receive()) == .appleIDEmailResolved("abc@privaterelay.appleid.com"))
        await sut.finish()

        #expect(spy.storedAppleIDEmails == ["abc@privaterelay.appleid.com"])
        #expect(sut.state.email == "abc@privaterelay.appleid.com")
        // Still asks for consent first, as a typed email would.
        #expect(sut.state.alert == .consent)
    }

    @Test("Without an email from Apple, the one it shared before is used")
    func appleIDFallsBackToStoredEmail() async throws {
        spy.storedAppleIDEmail = "abc@privaterelay.appleid.com"
        let sut = makeStore(state: .init(hasConsented: true))

        sut.send(.appleIDAuthorized(email: nil))
        #expect(try #require(await sut.receive()) == .appleIDEmailResolved("abc@privaterelay.appleid.com"))
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.storedAppleIDEmails.isEmpty)
        #expect(spy.updatedEmails == ["abc@privaterelay.appleid.com"])
    }

    @Test("With no email from Apple at all, the field asks for one")
    func appleIDWithoutAnyEmail() async throws {
        let sut = makeStore(state: .init(email: "typed@example.com", hasConsented: true))

        sut.send(.appleIDAuthorized(email: ""))
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.email == "")
        #expect(sut.state.emailError == .emailIsEmpty)
        #expect(spy.updatedEmails.isEmpty)
    }

    // MARK: Leaving

    @Test("Closing forgets the password and finishes")
    func closing() async {
        let sut = makeStore(state: .init(step: .done(email: "user@example.com", credentials: .stub)))

        sut.send(.closeTapped)
        await sut.finish()

        #expect(spy.clearPasswordCallCount == 1)
        #expect(spy.emittedOutputs == [.finished])
    }

    @Test("Logging out tells the host")
    func loggingOut() async throws {
        let sut = makeStore()

        sut.send(.logoutTapped)
        #expect(sut.state.isLoggingOut)
        #expect(try #require(await sut.receive()) == .logoutFinished(succeeded: true))
        await sut.finish()

        #expect(spy.logoutCallCount == 1)
        #expect(spy.emittedOutputs == [.loggedOut])
    }

    @Test("A failed logout keeps the screen up")
    func logoutFails() async throws {
        spy.logoutSucceeds = false
        let sut = makeStore()

        sut.send(.logoutTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(!sut.state.isLoggingOut)
        #expect(spy.emittedOutputs.isEmpty)
    }

    @Test("Submitting is ignored while logging out")
    func submitWhileLoggingOut() async {
        let sut = makeStore(state: .init(email: "user@example.com", hasConsented: true, isLoggingOut: true))

        sut.send(.submitTapped)
        await sut.finish()

        #expect(!sut.state.isSubmitting)
        #expect(spy.updatedEmails.isEmpty)
    }
}
