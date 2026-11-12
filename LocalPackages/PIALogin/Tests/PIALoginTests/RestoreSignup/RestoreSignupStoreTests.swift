//
//  RestoreSignupStoreTests.swift
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
struct RestoreSignupStoreTests {

    private let spy = RestoreSignupDependencySpy()

    private func makeStore(
        state: RestoreSignup.State = RestoreSignup.State(email: " someone@example.com ")
    ) -> TestStore<RestoreSignup.State, RestoreSignup.Action> {
        TestStore(
            initial: state,
            reduce: RestoreSignup.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    @Test("A successful restore hands the trimmed email to the host")
    func restoreSucceeds() async throws {
        let sut = makeStore()

        sut.send(.submitTapped)
        #expect(sut.state.isRestoring)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(!sut.state.isRestoring)
        #expect(spy.restoreCallCount == 1)
        #expect(spy.emittedOutputs == [.didRestore(email: "someone@example.com")])
    }

    @Test("An invalid email is flagged without restoring", arguments: ["", "not-an-email"])
    func invalidEmail(email: String) async {
        let sut = makeStore(state: .init(email: email))

        sut.send(.submitTapped)
        await sut.finish()

        #expect(sut.state.isEmailInvalid)
        #expect(!sut.state.isRestoring)
        #expect(spy.restoreCallCount == 0)
        #expect(spy.emittedOutputs.count == 1)
    }

    @Test("Editing the email clears the invalid flag")
    func editingClearsFlag() {
        let sut = makeStore(state: .init(email: "nope", isEmailInvalid: true))

        sut.send(.emailChanged("nope@"))

        #expect(sut.state.email == "nope@")
        #expect(!sut.state.isEmailInvalid)
    }

    @Test("Writing back the same text keeps the invalid flag")
    func sameTextKeepsFlag() {
        let sut = makeStore(state: .init(email: "nope", isEmailInvalid: true))

        sut.send(.emailChanged("nope"))

        #expect(sut.state.isEmailInvalid)
    }

    @Test("A second tap while restoring is ignored")
    func secondTapIgnored() async throws {
        let sut = makeStore()

        sut.send(.submitTapped)
        sut.send(.submitTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.restoreCallCount == 1)
    }

    @Test(
        "A failed restore shows its message and lets the person retry",
        arguments: [
            (RestoreSignupError.nothingToRestore, L10n.Account.Restore.Failure.message),
            (.failed(message: "Boom"), "Boom")
        ]
    )
    func restoreFails(error: RestoreSignupError, message: String) async throws {
        spy.restoreResult = .failure(error)
        let sut = makeStore()

        sut.send(.submitTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(!sut.state.isRestoring)
        #expect(spy.emittedOutputs == [.showError(message: message)])
    }

    @Test("The live dependency maps library errors", arguments: [ClientError.noReceipt, .badReceipt])
    func liveMapsMissingReceipt(error: ClientError) async {
        let dependencies = RestoreSignup.Dependencies.live(restorePurchases: { error }, emit: { _ in })

        #expect(await dependencies.restorePurchases() == .failure(.nothingToRestore))
    }

    @Test("The live dependency succeeds when the sync does")
    func liveSucceeds() async {
        let dependencies = RestoreSignup.Dependencies.live(restorePurchases: { nil }, emit: { _ in })

        #expect(await dependencies.restorePurchases() == .success(Success()))
    }
}
