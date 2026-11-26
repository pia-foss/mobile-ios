//
//  AutomationSettingsReducerTests.swift
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
struct AutomationSettingsReducerTests {
    @MainActor
    private final class Spy {
        var isAutomationEnabled = false
        var savedValues: [Bool] = []
        var showManageAutomationCount = 0
    }

    private let spy = Spy()
    private let changes = AsyncStream.makeStream(of: Void.self)

    private func makeStore(isAutomationEnabled: Bool = false) -> TestStore<AutomationSettings.State, AutomationSettings.Action> {
        let spy = spy
        let stream = changes.stream
        let reducer = AutomationSettings.Reducer(
            dependencies: .init(
                isAutomationEnabled: { spy.isAutomationEnabled },
                preferencesChanges: { stream },
                setAutomationEnabled: { spy.savedValues.append($0) },
                showManageAutomation: { spy.showManageAutomationCount += 1 },
            )
        )
        return TestStore(initial: .init(isAutomationEnabled: isAutomationEnabled), reduce: reducer.reduce)
    }

    @Test func togglingAutomationUpdatesStateAndPersists() async {
        let store = makeStore(isAutomationEnabled: false)

        store.send(.automationToggled(true))
        #expect(store.state.isAutomationEnabled)

        await store.finish()
        #expect(spy.savedValues == [true])
    }

    @Test func togglingToTheCurrentValueDoesNothing() async {
        let store = makeStore(isAutomationEnabled: true)

        store.send(.automationToggled(true))
        await store.finish()

        #expect(store.state.isAutomationEnabled)
        #expect(spy.savedValues.isEmpty)
    }

    @Test func manageAutomationTappedShowsManageAutomation() async {
        let store = makeStore()

        store.send(.manageAutomationTapped)
        await store.finish()

        #expect(spy.showManageAutomationCount == 1)
        #expect(store.unconsumedActionCount == 0)
    }

    @Test func preferencesChangeReloadsAutomationState() async {
        let store = makeStore(isAutomationEnabled: false)
        store.send(.onAppear)

        spy.isAutomationEnabled = true
        changes.continuation.yield()

        let received = await store.receive()
        #expect(received == .preferencesLoaded(isAutomationEnabled: true))
        #expect(store.state.isAutomationEnabled)

        await store.finish()
    }

    @Test func preferencesLoadedOverwritesState() {
        let store = makeStore(isAutomationEnabled: true)

        store.send(.preferencesLoaded(isAutomationEnabled: false))

        #expect(!store.state.isAutomationEnabled)
    }
}
