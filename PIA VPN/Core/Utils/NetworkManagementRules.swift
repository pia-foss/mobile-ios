//
//  NetworkManagementRules.swift
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

import PIALibrary

/// Reads and edits the Network Management (Automation) rules stored in the preferences.
///
/// Changes are committed straight to `Client.preferences`, as the Trusted Networks screens always
/// did; Settings picks them up when it closes.
struct NetworkManagementRules: Sendable {
    struct Rule: Equatable {
        let type: NMTType
        /// The Wi-Fi name, only for a `.trustedNetwork` rule
        let ssid: String?
        let rule: NMTRules
    }

    /// Macs have no cellular and can't read the Wi-Fi name, so only the Secure Wi-Fi rule applies there
    let isMacCatalyst: Bool
    private let currentWiFiNetwork: @Sendable () -> String?

    var canAddNetworks: Bool { !isMacCatalyst }

    init(
        isMacCatalyst: Bool = Self.isRunningOnMacCatalyst,
        currentWiFiNetwork: @escaping @Sendable () -> String? = { PIAHotspotHelper().currentWiFiNetwork() }
    ) {
        self.isMacCatalyst = isMacCatalyst
        self.currentWiFiNetwork = currentWiFiNetwork
    }

    /// The generic rules in display order, followed by the rules of each Wi-Fi network sorted by name
    func rules() -> [Rule] {
        let genericRules = Client.preferences.nmtGenericRules
            .compactMap { key, value -> Rule? in
                guard let type = NMTType(rawValue: key), type != .trustedNetwork,
                    let rule = NMTRules(rawValue: value)
                else { return nil }
                return Rule(type: type, ssid: nil, rule: rule)
            }
            .sorted { $0.type.order() < $1.type.order() }

        guard !isMacCatalyst else {
            return genericRules.filter { $0.type == .protectedWiFi }
        }

        let networkRules = Client.preferences.nmtTrustedNetworkRules
            .sorted { $0.key < $1.key }
            .compactMap { ssid, value in
                NMTRules(rawValue: value).map { Rule(type: .trustedNetwork, ssid: ssid, rule: $0) }
            }

        return genericRules + networkRules
    }

    /// The Wi-Fi networks seen recently, plus the current one, that don't have a rule yet
    func availableNetworks() -> [String] {
        let networksWithRules = Client.preferences.nmtTrustedNetworkRules.keys
        var networks = Client.preferences.availableNetworks.filter { !networksWithRules.contains($0) }
        if let current = currentWiFiNetwork(), !networks.contains(current), !networksWithRules.contains(current) {
            networks.append(current)
        }
        return networks
    }

    /// Sets the rule for Secure Wi-Fi, Open Wi-Fi or Mobile Data
    func setRule(_ rule: NMTRules, for type: NMTType) {
        guard type != .trustedNetwork else { return }
        let preferences = Client.preferences.editable()
        preferences.nmtGenericRules[type.rawValue] = rule.rawValue
        preferences.commit()
    }

    /// Adds or changes the rule for a Wi-Fi network
    func setRule(_ rule: NMTRules, forNetwork ssid: String) {
        let preferences = Client.preferences.editable()
        preferences.nmtTrustedNetworkRules[ssid] = rule.rawValue
        preferences.commit()
    }

    func removeNetwork(_ ssid: String) {
        let preferences = Client.preferences.editable()
        preferences.nmtTrustedNetworkRules[ssid] = nil
        preferences.commit()
    }

    static var isRunningOnMacCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
            true
        #else
            false
        #endif
    }
}
