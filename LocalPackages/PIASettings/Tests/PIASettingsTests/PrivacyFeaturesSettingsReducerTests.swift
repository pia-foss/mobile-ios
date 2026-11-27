//
//  PrivacyFeaturesSettingsReducerTests.swift
//  PIASettingsTests
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

@testable import PIASettings

@MainActor
@Suite
struct PrivacyFeaturesSettingsReducerTests {
    private typealias Preferences = PrivacyFeaturesSettings.Preferences

    @MainActor
    private final class Spy {
        var savedPreferences: [Preferences] = []
        var disableAutomationCount = 0
    }

    private let spy = Spy()

    private func makeStore(
        killSwitch: Bool,
        isAutomationEnabled: Bool
    ) -> TestStore<PrivacyFeaturesSettings.State, PrivacyFeaturesSettings.Action> {
        let spy = spy
        let preferences = Preferences(killSwitch: killSwitch, reconnectNotifications: killSwitch)
        let reducer = PrivacyFeaturesSettings.Reducer(
            dependencies: .init(
                loadPreferences: { preferences },
                isAutomationEnabled: { isAutomationEnabled },
                preferencesChanges: { AsyncStream { $0.finish() } },
                savePreferences: { spy.savedPreferences.append($0) },
                disableAutomation: { spy.disableAutomationCount += 1 },
                isContentBlockerEnabled: { false },
                appDidBecomeActive: { AsyncStream { $0.finish() } },
                reloadContentBlocker: {},
                showContentBlockerTutorial: {},
            )
        )
        return TestStore(
            initial: .init(preferences: preferences, isAutomationEnabled: isAutomationEnabled),
            reduce: reducer.reduce
        )
    }

    // MARK: - Kill switch without Automation

    @Test func turningKillSwitchOnSavesItWithReconnectNotifications() async {
        let store = makeStore(killSwitch: false, isAutomationEnabled: false)

        store.send(.killSwitchToggled(true))
        await store.finish()

        #expect(!store.state.isDisableKillSwitchConfirmationPresented)
        #expect(store.state.preferences == Preferences(killSwitch: true, reconnectNotifications: true))
        #expect(spy.savedPreferences == [Preferences(killSwitch: true, reconnectNotifications: true)])
        #expect(spy.disableAutomationCount == 0)
    }

    @Test func turningKillSwitchOffWithoutAutomationSavesWithoutAsking() async {
        let store = makeStore(killSwitch: true, isAutomationEnabled: false)

        store.send(.killSwitchToggled(false))
        await store.finish()

        #expect(!store.state.isDisableKillSwitchConfirmationPresented)
        #expect(store.state.preferences == Preferences(killSwitch: false, reconnectNotifications: false))
        #expect(spy.savedPreferences == [Preferences(killSwitch: false, reconnectNotifications: false)])
        #expect(spy.disableAutomationCount == 0)
    }

    @Test func togglingKillSwitchToTheCurrentValueDoesNothing() async {
        let store = makeStore(killSwitch: true, isAutomationEnabled: true)

        store.send(.killSwitchToggled(true))
        await store.finish()

        #expect(!store.state.isDisableKillSwitchConfirmationPresented)
        #expect(spy.savedPreferences.isEmpty)
        #expect(spy.disableAutomationCount == 0)
    }

    // MARK: - Turning the kill switch off while Automation is on

    @Test func turningKillSwitchOffWithAutomationAsksFirst() async {
        let store = makeStore(killSwitch: true, isAutomationEnabled: true)

        store.send(.killSwitchToggled(false))
        await store.finish()

        #expect(store.state.isDisableKillSwitchConfirmationPresented)
        #expect(store.state.preferences.killSwitch)
        #expect(store.state.isAutomationEnabled)
        #expect(spy.savedPreferences.isEmpty)
        #expect(spy.disableAutomationCount == 0)
    }

    @Test func confirmingTheDisableConfirmationTurnsBothOff() async {
        let store = makeStore(killSwitch: true, isAutomationEnabled: true)
        store.send(.killSwitchToggled(false))

        store.send(.disableKillSwitchConfirmed)
        await store.finish()

        #expect(!store.state.isDisableKillSwitchConfirmationPresented)
        #expect(!store.state.isAutomationEnabled)
        #expect(store.state.preferences == Preferences(killSwitch: false, reconnectNotifications: false))
        #expect(spy.savedPreferences == [Preferences(killSwitch: false, reconnectNotifications: false)])
        #expect(spy.disableAutomationCount == 1)
    }

    @Test func cancellingTheDisableConfirmationLeavesBothOn() async {
        let store = makeStore(killSwitch: true, isAutomationEnabled: true)
        store.send(.killSwitchToggled(false))

        store.send(.disableKillSwitchCancelled)
        await store.finish()

        #expect(!store.state.isDisableKillSwitchConfirmationPresented)
        #expect(store.state.isAutomationEnabled)
        #expect(store.state.preferences == Preferences(killSwitch: true, reconnectNotifications: true))
        #expect(spy.savedPreferences.isEmpty)
        #expect(spy.disableAutomationCount == 0)
    }
}
