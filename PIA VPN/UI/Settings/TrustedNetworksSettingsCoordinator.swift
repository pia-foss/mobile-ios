//
//  TrustedNetworksSettingsCoordinator.swift
//  PIA VPN
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

import Combine
import CoreArchitecture
import PIALibrary
import PIASettings
import UIKit

final class TrustedNetworksSettingsCoordinator: @MainActor FlowCoordinator {
    private weak var parent: UINavigationController?
    private weak var pendingPreferences: Client.Preferences.Editable?
    private weak var store: TrustedNetworksSettingsStore?
    private weak var host: UIViewController?
    private let networkRules: NetworkManagementRules
    private let subject = PassthroughSubject<Void, Never>()

    /// Finishes when the Trusted Networks screen leaves the navigation stack
    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(
        parent: UINavigationController,
        pendingPreferences: Client.Preferences.Editable,
        networkRules: NetworkManagementRules = .init()
    ) {
        self.parent = parent
        self.pendingPreferences = pendingPreferences
        self.networkRules = networkRules
    }

    @MainActor
    func start() {
        guard let parent else {
            subject.send(completion: .finished)
            return
        }

        let networkRules = networkRules
        let store = TrustedNetworksSettingsStore(
            initialState: .init(
                rules: networkRules.settingsRules(),
                canAddNetworks: networkRules.canAddNetworks,
                isKillSwitchWarningPresented: pendingPreferences?.isPersistentConnection == false && Client.preferences.nmtRulesEnabled
            ),
            dependencies: .init(
                loadRules: { networkRules.settingsRules() },
                loadAvailableNetworks: { networkRules.availableNetworks() },
                saveRule: { networkRules.save($1, for: $0) },
                appDidBecomeActive: { NotificationCenter.default.signals(named: UIApplication.didBecomeActiveNotification) },
                enableKillSwitch: { [weak self] in self?.pendingPreferences?.isPersistentConnection = true },
                showAddNetwork: { [weak self] in self?.showAddCustomNetworks() },
                didAddNetwork: { [weak self] in self?.returnToTrustedNetworks() },
            )
        )
        // Both hosts own the store through their root views, so it goes away with them
        self.store = store
        let host = NavigationHostingController(rootView: TrustedNetworksSettingsView(store: store)) { [subject] in
            subject.send(completion: .finished)
        }
        self.host = host
        parent.pushViewController(host, animated: true)
    }

    @MainActor
    private func showAddCustomNetworks() {
        guard let parent, let store else { return }
        let host = NavigationHostingController(rootView: AddCustomNetworksView(store: store)) {}
        parent.pushViewController(host, animated: true)
    }

    @MainActor
    private func returnToTrustedNetworks() {
        guard let parent, let host, parent.viewControllers.contains(host), parent.topViewController !== host else { return }
        parent.popToViewController(host, animated: true)
    }
}

// MARK: - Trusted Networks mapping

extension NetworkManagementRules {
    fileprivate func settingsRules() -> [TrustedNetworksSettings.Rule] {
        rules().compactMap(TrustedNetworksSettings.Rule.init)
    }

    fileprivate func save(_ behavior: TrustedNetworksSettings.Behavior?, for network: TrustedNetworksSettings.Network) {
        switch (network, behavior) {
        case (.custom(let ssid), let behavior?):
            setRule(behavior.rule, forNetwork: ssid)
        case (.custom(let ssid), nil):
            removeNetwork(ssid)
        case (_, let behavior?):
            guard let type = network.type else { return }
            setRule(behavior.rule, for: type)
        case (_, nil):
            // Only Wi-Fi networks can be removed
            break
        }
    }
}

extension TrustedNetworksSettings.Rule {
    fileprivate init?(_ rule: NetworkManagementRules.Rule) {
        let network: TrustedNetworksSettings.Network
        switch rule.type {
        case .protectedWiFi: network = .secureWiFi
        case .openWiFi: network = .openWiFi
        case .cellular: network = .mobileData
        case .trustedNetwork:
            guard let ssid = rule.ssid else { return nil }
            network = .custom(ssid: ssid)
        }
        self.init(network: network, behavior: .init(rule.rule))
    }
}

extension TrustedNetworksSettings.Network {
    fileprivate var type: NMTType? {
        switch self {
        case .secureWiFi: .protectedWiFi
        case .openWiFi: .openWiFi
        case .mobileData: .cellular
        case .custom: nil
        }
    }
}

extension TrustedNetworksSettings.Behavior {
    fileprivate init(_ rule: NMTRules) {
        switch rule {
        case .alwaysConnect: self = .alwaysConnect
        case .alwaysDisconnect: self = .alwaysDisconnect
        case .retainState: self = .retainState
        }
    }

    fileprivate var rule: NMTRules {
        switch self {
        case .alwaysConnect: .alwaysConnect
        case .alwaysDisconnect: .alwaysDisconnect
        case .retainState: .retainState
        }
    }
}
