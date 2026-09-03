//
//  WelcomeBackStoreTests.swift
//  PIAPaywallTests
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
import Testing

@testable import PIAPaywall

@MainActor
struct WelcomeBackStoreTests {

    private let spy = WelcomeBackDependencySpy()

    private func makeStore(
        state: WelcomeBack.State = WelcomeBack.State()
    ) -> TestStore<WelcomeBack.State, WelcomeBack.Action> {
        TestStore(
            initial: state,
            reduce: WelcomeBack.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    @Test("The App Store button restores once and reports the account")
    func restoreSignsIn() async throws {
        // GIVEN the screen as it is presented
        let sut = makeStore()

        // WHEN the App Store button is tapped
        sut.send(.appStoreAccountTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        // THEN exactly one restore ran and the account reached the host
        #expect(spy.restoreCallCount == 1)
        #expect(spy.authenticatedUsers.count == 1)
        #expect(!sut.state.isRestoring)
    }

    @Test("A failed restore asks the host to dismiss")
    func failedRestoreDismisses() async throws {
        // GIVEN a receipt that cannot be signed in with
        spy.restoreResult = .failure(.restoreLoginFailed)
        let sut = makeStore()

        // WHEN the App Store button is tapped
        sut.send(.appStoreAccountTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        // THEN the screen goes away rather than explaining itself, revealing the paywall
        #expect(spy.didDismiss)
        #expect(spy.authenticatedUsers.isEmpty)
        #expect(!sut.state.isRestoring)
    }

    @Test("The credentials button asks the host for the login screen")
    func credentialsRequestsLogin() async {
        // GIVEN the screen as it is presented
        let sut = makeStore()

        // WHEN the credentials button is tapped
        sut.send(.usernameAndPasswordTapped)
        await sut.finish()

        // THEN the host is asked to show login, and no restore was attempted
        #expect(spy.didRequestLogin)
        #expect(spy.restoreCallCount == 0)
    }
}
