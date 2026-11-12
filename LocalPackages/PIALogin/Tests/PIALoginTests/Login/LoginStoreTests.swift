//
//  LoginStoreTests.swift
//  PIALoginTests
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
import PIALocalizations
import Testing

@testable import PIALogin

@MainActor
struct LoginStoreTests {

    private let spy = LoginDependencySpy()

    private func makeStore(
        state: Login.State = Login.State(username: "p1234567", password: "secret")
    ) -> TestStore<Login.State, Login.Action> {
        TestStore(
            initial: state,
            reduce: Login.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    // MARK: Credentials

    @Test("Valid credentials sign in and report the account")
    func credentialsSignIn() async throws {
        let sut = makeStore(state: .init(username: " p1234567 ", password: "secret\n"))

        sut.send(.loginTapped)
        #expect(sut.state.inFlight == .credentials)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.inFlight == nil)
        #expect(spy.loggedInCredentials == [Credentials(username: "p1234567", password: "secret")])
        #expect(spy.emittedOutputs == [.didLogin(.stub)])
    }

    @Test(
        "Empty fields are flagged without calling the backend",
        arguments: [
            ("", "", Set<Login.Field>([.username, .password])),
            ("  ", "secret", Set<Login.Field>([.username])),
            ("p1234567", "", Set<Login.Field>([.password]))
        ]
    )
    func emptyFieldsAreFlagged(username: String, password: String, invalid: Set<Login.Field>) async {
        let sut = makeStore(state: .init(username: username, password: password))

        sut.send(.loginTapped)
        await sut.finish()

        #expect(sut.state.invalidFields == invalid)
        #expect(sut.state.inFlight == nil)
        #expect(spy.loggedInCredentials.isEmpty)
        #expect(spy.emittedOutputs == [.showError(message: L10n.Welcome.Login.Error.validation, duration: nil)])
    }

    @Test("Editing a flagged field clears its flag")
    func editingClearsFlag() {
        let sut = makeStore(state: .init(invalidFields: [.username, .password]))

        sut.send(.usernameChanged("p"))

        #expect(sut.state.username == "p")
        #expect(sut.state.invalidFields == [.password])
    }

    @Test("A second tap while signing in is ignored")
    func secondTapIgnored() async throws {
        let sut = makeStore()

        sut.send(.loginTapped)
        sut.send(.loginTapped)
        sut.send(.receiptLoginTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.loggedInCredentials.count == 1)
        #expect(spy.receiptLoginCount == 0)
    }

    @Test("Wrong credentials show the backend's error")
    func wrongCredentials() async throws {
        spy.loginResult = .failure(.unauthorized)
        let sut = makeStore()

        sut.send(.loginTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.inFlight == nil)
        #expect(spy.emittedOutputs == [.showError(message: L10n.Welcome.Login.Error.unauthorized, duration: nil)])
    }

    @Test("An expired account asks the host for a new plan")
    func expiredAccount() async throws {
        spy.loginResult = .failure(.expired)
        let sut = makeStore()

        sut.send(.loginTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.emittedOutputs == [.accountExpired])
    }

    // MARK: Throttling

    @Test("A throttled method is refused locally until the window passes")
    func throttling() async throws {
        spy.loginResult = .failure(.throttled(retryAfter: 30))
        let sut = makeStore()

        sut.send(.loginTapped)
        _ = try #require(await sut.receive())
        await sut.finish()
        #expect(sut.state.retryAfter[.credentials] == spy.now.addingTimeInterval(30))

        spy.now = spy.now.addingTimeInterval(10)
        sut.send(.loginTapped)
        await sut.finish()

        #expect(spy.loggedInCredentials.count == 1)
        #expect(
            spy.emittedOutputs.last == .showError(message: L10n.Welcome.Login.Error.throttled("20"), duration: 20)
        )

        spy.now = spy.now.addingTimeInterval(20)
        spy.loginResult = .success(.stub)
        sut.send(.loginTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.loggedInCredentials.count == 2)
        #expect(spy.emittedOutputs.last == .didLogin(.stub))
    }

    @Test("Throttling one method leaves the others usable")
    func throttlingIsPerMethod() async throws {
        let sut = makeStore(state: .init(retryAfter: [.credentials: spy.now.addingTimeInterval(60)]))

        sut.send(.receiptLoginTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.receiptLoginCount == 1)
    }

    // MARK: Receipt

    @Test("Signing in with the receipt reports the account")
    func receiptSignIn() async throws {
        let sut = makeStore()

        sut.send(.receiptLoginTapped)
        #expect(sut.state.inFlight == .receipt)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.emittedOutputs == [.didLogin(.stub)])
    }

    @Test("A missing or rejected receipt shows the restore alert")
    func badReceipt() async throws {
        spy.receiptResult = .failure(.badReceipt)
        let sut = makeStore()

        sut.send(.receiptLoginTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.isBadReceiptAlertPresented)
        #expect(spy.emittedOutputs.isEmpty)

        sut.send(.alertDismissed)
        #expect(!sut.state.isBadReceiptAlertPresented)
    }

    // MARK: Magic link

    @Test("Sending a magic link to a valid email confirms it was sent")
    func magicLinkSent() async throws {
        let sut = makeStore()

        sut.send(.magicLinkTapped)
        #expect(sut.state.isMagicLinkPromptPresented)
        sut.send(.magicLinkEmailChanged(" someone@example.com "))
        sut.send(.magicLinkSendTapped)
        #expect(!sut.state.isMagicLinkPromptPresented)
        #expect(sut.state.inFlight == .magicLink)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.inFlight == nil)
        #expect(spy.requestedEmails == ["someone@example.com"])
        #expect(spy.emittedOutputs == [.showMessage(L10n.Welcome.Login.Magic.Link.response)])
    }

    @Test("An invalid email is rejected without calling the backend", arguments: ["", "not-an-email"])
    func magicLinkInvalidEmail(email: String) async {
        let sut = makeStore()

        sut.send(.magicLinkTapped)
        sut.send(.magicLinkEmailChanged(email))
        sut.send(.magicLinkSendTapped)
        await sut.finish()

        #expect(spy.requestedEmails.isEmpty)
        #expect(spy.emittedOutputs.count == 1)
    }

    @Test("Reopening the prompt starts with an empty email")
    func promptResets() {
        let sut = makeStore(state: .init(magicLinkEmail: "old@example.com"))

        sut.send(.magicLinkTapped)

        #expect(sut.state.magicLinkEmail.isEmpty)
    }

    @Test("A magic link opened while the screen is up signs in")
    func magicLinkToken() async throws {
        let sut = makeStore()

        sut.send(.onAppear)
        await Task.yield()
        spy.openMagicLink(token: "token")
        #expect(try #require(await sut.receive()) == .magicLinkTokenReceived("token"))
        #expect(sut.state.inFlight == .magicLinkToken)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.redeemedTokens == ["token"])
        #expect(spy.emittedOutputs == [.didLogin(.stub)])
    }

    @Test("A magic link token that fails shows the connectivity error")
    func magicLinkTokenFails() async throws {
        spy.tokenResult = .failure(.unauthorized)
        let sut = makeStore()

        sut.send(.magicLinkTokenReceived("token"))
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(
            spy.emittedOutputs == [.showError(message: L10n.Welcome.Purchase.Error.Connectivity.title, duration: nil)]
        )
    }

    // MARK: Navigation

    @Test("Restore asks the host for the restore screen")
    func restore() async {
        let sut = makeStore()

        sut.send(.restorePurchaseTapped)
        await sut.finish()

        #expect(spy.emittedOutputs == [.restorePurchaseRequested])
    }

    // MARK: Error mapping

    @Test(
        "Library errors map to what the screen treats differently",
        arguments: [
            (ClientError.noReceipt, LoginError.badReceipt),
            (.badReceipt, .badReceipt),
            (.throttled(retryAfter: 5), .throttled(retryAfter: 5)),
            (.libraryError(code: 7, message: "boom"), .internal(code: 7)),
            (.unknown(code: 3, message: "huh"), .unknown(message: "huh", code: 3))
        ]
    )
    func errorMapping(client: ClientError, expected: LoginError) {
        #expect(LoginError(client) == expected)
    }
}
