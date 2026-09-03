//
//  WelcomeBackReducerTests.swift
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

import Testing

@testable import PIAPaywall

@MainActor
struct WelcomeBackReducerTests {

    private let sut = WelcomeBack.Reducer(dependencies: .test())

    @Test("Tapping App Store Account starts a restore")
    func appStoreTapStartsRestore() {
        // GIVEN an idle screen
        var state = WelcomeBack.State()

        // WHEN the App Store button is tapped
        let effect = sut.reduce(&state, .appStoreAccountTapped)

        // THEN the button shows its spinner and work is scheduled
        #expect(state.isRestoring)
        #expect(effect != nil)
    }

    @Test("A second tap while restoring does nothing")
    func secondTapIsIgnored() {
        // GIVEN a restore already in flight
        var state = WelcomeBack.State(isRestoring: true)

        // WHEN the App Store button is tapped again
        let effect = sut.reduce(&state, .appStoreAccountTapped)

        // THEN no second restore is scheduled
        #expect(state.isRestoring)
        #expect(effect == nil)
    }

    @Test("A successful restore clears the spinner")
    func successClearsSpinner() {
        // GIVEN a restore in flight
        var state = WelcomeBack.State(isRestoring: true)

        // WHEN it signs the customer in
        let effect = sut.reduce(&state, .restoreSucceeded(.init(Stub.user)))

        // THEN the screen settles and the outcome is reported
        #expect(!state.isRestoring)
        #expect(effect != nil)
    }

    @Test("A failed restore clears the spinner")
    func failureClearsSpinner() {
        // GIVEN a restore in flight
        var state = WelcomeBack.State(isRestoring: true)

        // WHEN it fails
        let effect = sut.reduce(&state, .restoreFailed)

        // THEN the screen settles and the dismissal is reported
        #expect(!state.isRestoring)
        #expect(effect != nil)
    }

    @Test("The credentials button is inert while a restore is in flight")
    func loginIsBlockedDuringRestore() {
        // GIVEN a restore in flight
        var state = WelcomeBack.State(isRestoring: true)

        // WHEN the credentials button is tapped
        let effect = sut.reduce(&state, .usernameAndPasswordTapped)

        // THEN nothing leaves the screen
        #expect(effect == nil)
    }
}
