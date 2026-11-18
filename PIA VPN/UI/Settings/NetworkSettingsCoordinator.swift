//
//  NetworkSettingsCoordinator.swift
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

final class NetworkSettingsCoordinator: @MainActor FlowCoordinator {
    private weak var parent: UINavigationController?
    private weak var host: UIViewController?
    private weak var pendingPreferences: Client.Preferences.Editable?
    private weak var settingsDelegate: SettingsDelegate?
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(
        parent: UINavigationController,
        pendingPreferences: Client.Preferences.Editable,
        settingsDelegate: SettingsDelegate
    ) {
        self.parent = parent
        self.pendingPreferences = pendingPreferences
        self.settingsDelegate = settingsDelegate
    }

    @MainActor
    func start() {
        guard let parent else {
            subject.send(completion: .finished)
            return
        }

        let view = NetworkSettingsView(
            dependencies: .init(
                loadPreferences: { [weak self] in self?.preferences() ?? .init(presets: [], customServers: [], dns: .preset("")) },
                isEditable: { Flags.shared.enablesDNSSettings },
                preferencesChanges: { NotificationCenter.default.signals(named: .PIASettingsHaveChanged) },
                setDNS: { [weak self] dns in
                    guard let self else { return }
                    switch dns {
                    case .preset(let name): applyDNS(key: name)
                    case .custom: applyDNS(key: customKey)
                    }
                },
                showCustomDNS: { [weak self] in self?.showCustomDNS() },
            )
        )
        let host = NavigationHostingController(rootView: view) { [subject] in
            subject.send(completion: .finished)
        }
        self.host = host
        parent.pushViewController(host, animated: true)
    }

    @MainActor
    private func showCustomDNS() {
        guard let parent else { return }
        let view = CustomDNSSettingsView(
            servers: DNSList.shared.valueForKey(customKey),
            dependencies: .init(
                save: { [weak self] servers in
                    guard let self else { return }
                    DNSList.shared.addNewServerWithName(customKey, andIPs: servers)
                    applyDNS(key: customKey)
                },
                clear: { [weak self] in
                    guard let self else { return }
                    DNSList.shared.removeServer(name: customKey)
                    if let firstKey = DNSList.shared.firstKey() {
                        applyDNS(key: firstKey)
                    }
                },
                dismiss: { [weak self] in
                    guard let self, let host else { return }
                    parent.popToViewController(host, animated: true)
                },
            )
        )
        parent.pushViewController(NavigationHostingController(rootView: view) {}, animated: true)
    }

    @MainActor
    private func applyDNS(key: String) {
        settingsDelegate?.updateSetting(NetworkSections.dns, withValue: key)
        Macros.postNotification(.PIASettingsHaveChanged)
    }

    @MainActor
    private var customKey: String {
        pendingPreferences?.vpnType == KapePlatformSDKVPNType.openVPN.rawValue
            ? DNSList.CUSTOM_OPENVPN_DNS_KEY
            : DNSList.CUSTOM_WIREGUARD_DNS_KEY
    }

    @MainActor
    private var currentServers: [String] {
        guard let pendingPreferences else { return [] }
        return pendingPreferences.vpnType == KapePlatformSDKVPNType.wireGuard.rawValue
            ? pendingPreferences.wireGuardDnsServers
            : pendingPreferences.openVPNDnsServers
    }

    @MainActor
    private func preferences() -> NetworkSettings.Preferences {
        let customKeys = [DNSList.CUSTOM_OPENVPN_DNS_KEY, DNSList.CUSTOM_WIREGUARD_DNS_KEY]
        let presets = (DNSList.shared.dnsList ?? [])
            .flatMap { $0 }
            .filter { !customKeys.contains($0.key) }
        let customServers = DNSList.shared.valueForKey(customKey)
        let servers = currentServers

        let dns: NetworkSettings.DNS =
            if !customServers.isEmpty, servers == customServers {
                .custom
            } else {
                .preset(presets.first { $0.value == servers }?.key ?? presets.first?.key ?? "")
            }
        return .init(presets: presets.map(\.key), customServers: customServers, dns: dns)
    }
}
