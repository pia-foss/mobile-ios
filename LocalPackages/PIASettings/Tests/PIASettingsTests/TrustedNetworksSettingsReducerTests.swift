//
//  TrustedNetworksSettingsReducerTests.swift
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
struct TrustedNetworksSettingsReducerTests {
    typealias Feature = TrustedNetworksSettings

    @MainActor
    private final class Spy {
        enum Event: Equatable {
            case saved(Feature.Network, Feature.Behavior?)
            case enabledKillSwitch
            case showedAddNetwork
            case addedNetwork
        }

        var rules: [Feature.Rule] = []
        var availableNetworks: [String] = []
        var events: [Event] = []
    }

    private static let genericRules: [Feature.Rule] = [
        .init(network: .secureWiFi, behavior: .alwaysConnect),
        .init(network: .openWiFi, behavior: .alwaysDisconnect),
        .init(network: .mobileData, behavior: .retainState)
    ]

    private let spy = Spy()
    private let appDidBecomeActive = AsyncStream.makeStream(of: Void.self)

    private func makeStore(
        rules: [Feature.Rule] = genericRules,
        availableNetworks: [String] = [],
        isKillSwitchWarningPresented: Bool = false
    ) -> TestStore<Feature.State, Feature.Action> {
        let spy = spy
        let stream = appDidBecomeActive.stream
        let reducer = Feature.Reducer(
            dependencies: .init(
                loadRules: { spy.rules },
                loadAvailableNetworks: { spy.availableNetworks },
                saveRule: { spy.events.append(.saved($0, $1)) },
                appDidBecomeActive: { stream },
                enableKillSwitch: { spy.events.append(.enabledKillSwitch) },
                showAddNetwork: { spy.events.append(.showedAddNetwork) },
                didAddNetwork: { spy.events.append(.addedNetwork) },
            )
        )
        var state = Feature.State(
            rules: rules,
            canAddNetworks: true,
            isKillSwitchWarningPresented: isKillSwitchWarningPresented
        )
        state.availableNetworks = availableNetworks
        return TestStore(initial: state, reduce: reducer.reduce)
    }

    // MARK: - Rules

    @Test func selectingABehaviorUpdatesTheRuleAndSavesIt() async {
        let store = makeStore()

        store.send(.behaviorSelected(.openWiFi, .alwaysConnect))
        #expect(store.state.rules[1] == .init(network: .openWiFi, behavior: .alwaysConnect))

        await store.finish()
        #expect(spy.events == [.saved(.openWiFi, .alwaysConnect)])
    }

    @Test func selectingTheCurrentBehaviorSavesNothing() async {
        let store = makeStore()

        store.send(.behaviorSelected(.secureWiFi, .alwaysConnect))
        await store.finish()

        #expect(store.state.rules == Self.genericRules)
        #expect(spy.events.isEmpty)
    }

    @Test func selectingABehaviorForANetworkWithoutARuleDoesNothing() async {
        let store = makeStore()

        store.send(.behaviorSelected(.custom(ssid: "Office"), .alwaysConnect))
        await store.finish()

        #expect(store.state.rules == Self.genericRules)
        #expect(spy.events.isEmpty)
    }

    @Test func removingANetworkDropsItsRuleAndSavesNoBehavior() async {
        let home = Feature.Rule(network: .custom(ssid: "Home"), behavior: .alwaysDisconnect)
        let store = makeStore(rules: Self.genericRules + [home])

        store.send(.removeTapped(ssid: "Home"))
        #expect(store.state.rules == Self.genericRules)

        await store.finish()
        #expect(spy.events == [.saved(.custom(ssid: "Home"), nil)])
    }

    // MARK: - Adding a network

    @Test func addRuleTappedShowsTheAddScreen() async {
        let store = makeStore()

        store.send(.addRuleTapped)
        await store.finish()

        #expect(spy.events == [.showedAddNetwork])
    }

    @Test func addScreenAppearingLoadsTheAvailableNetworks() async {
        spy.availableNetworks = ["Cafe", "Office"]
        let store = makeStore()

        store.send(.addNetworkAppeared)

        #expect(await store.receive() == .availableNetworksLoaded(["Cafe", "Office"]))
        #expect(store.state.availableNetworks == ["Cafe", "Office"])
    }

    @Test func selectingANetworkSavesItReportsItAndReloadsTheRules() async {
        let office = Feature.Rule(network: .custom(ssid: "Office"), behavior: .alwaysConnect)
        spy.rules = Self.genericRules + [office]
        let store = makeStore(availableNetworks: ["Cafe", "Office"])

        store.send(.customNetworkSelected(ssid: "Office", .alwaysConnect))
        #expect(store.state.availableNetworks == ["Cafe"])

        #expect(await store.receive() == .rulesLoaded(Self.genericRules + [office]))
        #expect(store.state.rules == Self.genericRules + [office])
        // Saved before the coordinator is told, so the screen it returns to shows the new rule
        #expect(spy.events == [.saved(.custom(ssid: "Office"), .alwaysConnect), .addedNetwork])
    }

    // MARK: - Refresh

    @Test func becomingActiveReloadsRulesAndAvailableNetworks() async {
        let store = makeStore()
        store.send(.onAppear)

        let home = Feature.Rule(network: .custom(ssid: "Home"), behavior: .retainState)
        spy.rules = Self.genericRules + [home]
        spy.availableNetworks = ["Cafe"]
        appDidBecomeActive.continuation.yield()

        #expect(await store.receive() == .rulesLoaded(Self.genericRules + [home]))
        #expect(await store.receive() == .availableNetworksLoaded(["Cafe"]))
        #expect(store.state.rules == Self.genericRules + [home])
        #expect(store.state.availableNetworks == ["Cafe"])

        await store.finish()
    }

    // MARK: - Kill switch warning

    @Test func confirmingTheKillSwitchWarningEnablesKillSwitch() async {
        let store = makeStore(isKillSwitchWarningPresented: true)

        store.send(.killSwitchWarningConfirmed)
        #expect(!store.state.isKillSwitchWarningPresented)

        await store.finish()
        #expect(spy.events == [.enabledKillSwitch])
    }

    @Test func dismissingTheKillSwitchWarningLeavesKillSwitchAlone() async {
        let store = makeStore(isKillSwitchWarningPresented: true)

        store.send(.killSwitchWarningDismissed)
        await store.finish()

        #expect(!store.state.isKillSwitchWarningPresented)
        #expect(spy.events.isEmpty)
    }
}
