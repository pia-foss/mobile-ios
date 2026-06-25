//
//  KapePlatformSDKTunnelProfile+OpenVPN.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 09.06.26.
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

extension KapePlatformSDKTunnelProfile {
    /// Resolved OpenVPN parameters written into `PIATunnelSharedState.State`.
    struct OpenVPNSettings {
        let caCertificate: String
        let username: String
        let password: String
        let ovpnConfig: String
        let port: UInt16
        let transport: PIATunnelSharedState.OpenVPNTransport
        let mtu: UInt16
        /// User-selected custom DNS resolvers; empty → keep the server-provided resolvers.
        let dnsServers: [String]
    }

    /// Builds the OpenVPN settings from app-group UserDefaults.
    /// For a Dedicated IP server, authenticates with the per-server DIP credentials
    /// (`dipUsername` + the dedicated IP as password) instead of the account VPN token.
    /// Throws if (non-DIP) VPN credentials are unavailable.
    func openVPNSettings(for server: Server) throws -> OpenVPNSettings {
        let caCertificate = Client.configuration.rsa4096Certificate ?? ""

        let username: String
        let password: String
        if let dipUsername = server.dipUsername, server.dipToken != nil {
            // DIP: username is the dedicated_ip_* identity; password is the dedicated IP itself
            // (what `DedicatedIPTokenHandler` stored, identical to the server's single address IP).
            guard let dipIp = server.openVPNAddressesForUDP?.first?.ip ?? server.openVPNAddressesForTCP?.first?.ip else {
                throw NSError(
                    domain: "PIAVPNError", code: 3,
                    userInfo: [NSLocalizedDescriptionKey: "Dedicated IP address not available for \(server.identifier)"])
            }
            username = dipUsername
            password = dipIp
        } else {
            guard
                let accountUsername = Client.providers.accountProvider.vpnTokenUsername,
                let accountPassword = Client.providers.accountProvider.vpnTokenPassword,
                !accountUsername.isEmpty, !accountPassword.isEmpty
            else {
                throw NSError(
                    domain: "PIAVPNError", code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "VPN credentials not available — token not yet refreshed"])
            }
            username = accountUsername
            password = accountPassword
        }

        let cipher = sharedDefaults.string(forKey: AppConstants.UserDefaultsKeys.OpenVPN.cipher) ?? "AES-128-GCM"
        let auth = sharedDefaults.string(forKey: AppConstants.UserDefaultsKeys.OpenVPN.auth) ?? "SHA256"
        let ovpnConfig = "cipher \(cipher)\nauth \(auth)"

        // 0 means automatic; the extension picks per-transport defaults.
        let port = UInt16(sharedDefaults.integer(forKey: AppConstants.UserDefaultsKeys.OpenVPN.port))

        // `PIASocketType` holds a SocketType raw value ("UDP"/"TCP"); absent = automatic (try both).
        let transport: PIATunnelSharedState.OpenVPNTransport =
            switch sharedDefaults.string(forKey: AppConstants.UserDefaultsKeys.OpenVPN.transport) {
            case "UDP": .udp
            case "TCP": .tcp
            default: .automatic
            }

        let useSmallPackets = sharedDefaults.bool(forKey: AppConstants.UserDefaultsKeys.OpenVPN.useSmallPackets)
        let mtu = UInt16(useSmallPackets ? AppConstants.OpenVPNPacketSize.smallPacketSize : AppConstants.OpenVPNPacketSize.defaultPacketSize)
        let dnsServers = customDnsServers(forVPNType: .openVPN)

        return OpenVPNSettings(
            caCertificate: caCertificate,
            username: username,
            password: password,
            ovpnConfig: ovpnConfig,
            port: port,
            transport: transport,
            mtu: mtu,
            dnsServers: dnsServers)
    }
}
