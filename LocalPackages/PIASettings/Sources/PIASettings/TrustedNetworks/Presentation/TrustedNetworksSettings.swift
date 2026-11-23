//
//  TrustedNetworksSettings.swift
//  PIASettings
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

import Foundation

public enum TrustedNetworksSettings {}

extension TrustedNetworksSettings {
    public enum Network: Hashable, Sendable {
        case secureWiFi
        case openWiFi
        case mobileData
        case custom(ssid: String)
    }

    public enum Behavior: CaseIterable, Sendable {
        case alwaysConnect
        case alwaysDisconnect
        case retainState
    }

    public struct Rule: Equatable, Identifiable, Sendable {
        public let network: Network
        public var behavior: Behavior

        public var id: Network { network }

        public init(network: Network, behavior: Behavior) {
            self.network = network
            self.behavior = behavior
        }
    }

    public struct State: Equatable, Sendable {
        public var rules: [Rule]
        public var availableNetworks: [String] = []
        public let canAddNetworks: Bool
        public var isKillSwitchWarningPresented: Bool

        public init(rules: [Rule], canAddNetworks: Bool, isKillSwitchWarningPresented: Bool) {
            self.rules = rules
            self.canAddNetworks = canAddNetworks
            self.isKillSwitchWarningPresented = isKillSwitchWarningPresented
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case addNetworkAppeared
        case rulesLoaded([Rule])
        case availableNetworksLoaded([String])
        case behaviorSelected(Network, Behavior)
        case removeTapped(ssid: String)
        case addRuleTapped
        case customNetworkSelected(ssid: String, Behavior)
        case killSwitchWarningConfirmed
        case killSwitchWarningDismissed
    }

    public struct Dependencies: Sendable {
        public let loadRules: @MainActor @Sendable () -> [Rule]
        public let loadAvailableNetworks: @MainActor @Sendable () -> [String]
        /// Saves the behavior for a network, or removes its rule when `nil`
        public let saveRule: @MainActor @Sendable (Network, Behavior?) -> Void
        public let appDidBecomeActive: @Sendable () -> AsyncStream<Void>
        public let enableKillSwitch: @MainActor @Sendable () -> Void
        public let showAddNetwork: @MainActor @Sendable () -> Void
        /// Reports that a Wi-Fi network got a rule; the coordinator decides what comes next
        public let didAddNetwork: @MainActor @Sendable () -> Void

        public init(
            loadRules: @MainActor @Sendable @escaping () -> [Rule],
            loadAvailableNetworks: @MainActor @Sendable @escaping () -> [String],
            saveRule: @MainActor @Sendable @escaping (Network, Behavior?) -> Void,
            appDidBecomeActive: @Sendable @escaping () -> AsyncStream<Void>,
            enableKillSwitch: @MainActor @Sendable @escaping () -> Void,
            showAddNetwork: @MainActor @Sendable @escaping () -> Void,
            didAddNetwork: @MainActor @Sendable @escaping () -> Void,
        ) {
            self.loadRules = loadRules
            self.loadAvailableNetworks = loadAvailableNetworks
            self.saveRule = saveRule
            self.appDidBecomeActive = appDidBecomeActive
            self.enableKillSwitch = enableKillSwitch
            self.showAddNetwork = showAddNetwork
            self.didAddNetwork = didAddNetwork
        }
    }
}
