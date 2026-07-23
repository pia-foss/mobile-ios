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
    /// Failures that prevent building OpenVPN settings for a server.
    enum OpenVPNSettingsError: LocalizedError {
        /// A Dedicated IP server has no resolvable IP to use as the DIP password.
        case dedicatedIPUnavailable(serverIdentifier: String)
        /// The account VPN token hasn't been refreshed yet, so no credentials are available.
        case vpnCredentialsUnavailable

        var errorDescription: String? {
            switch self {
            case .dedicatedIPUnavailable(let serverIdentifier):
                return "Dedicated IP address not available for \(serverIdentifier)"
            case .vpnCredentialsUnavailable:
                return "VPN credentials not available — token not yet refreshed"
            }
        }
    }

    /// Builds the OpenVPN settings from app-group UserDefaults.
    /// For a Dedicated IP server, authenticates with the per-server DIP credentials
    /// (`dipUsername` + the dedicated IP as password) instead of the account VPN token.
    /// Throws if (non-DIP) VPN credentials are unavailable.
    func openVPNSettings(for server: Server) throws(OpenVPNSettingsError) -> PIATunnelSharedState.OpenVPNSettings {
        let caCertificate = Client.configuration.rsa4096Certificate ?? ""

        let username: String
        let password: String
        if let dipUsername = server.dipUsername, server.dipToken != nil {
            // DIP: username is the dedicated_ip_* identity; password is the dedicated IP itself
            // (what `DedicatedIPTokenHandler` stored, identical to the server's single address IP).
            guard let dipIp = server.openVPNAddressesForUDP?.first?.ip ?? server.openVPNAddressesForTCP?.first?.ip else {
                throw .dedicatedIPUnavailable(serverIdentifier: server.identifier)
            }
            username = dipUsername
            password = dipIp
        } else {
            guard
                let accountUsername = Client.providers.accountProvider.vpnTokenUsername,
                let accountPassword = Client.providers.accountProvider.vpnTokenPassword,
                !accountUsername.isEmpty, !accountPassword.isEmpty
            else {
                throw .vpnCredentialsUnavailable
            }
            username = accountUsername
            password = accountPassword
        }

        let cipher = sharedDefaults.string(forKey: AppConstants.UserDefaultsKeys.OpenVPN.cipher) ?? AppConstants.OpenVPNCrypto.default.rawValue
        let auth = sharedDefaults.string(forKey: AppConstants.UserDefaultsKeys.OpenVPN.auth) ?? AppConstants.OpenVPNCrypto.defaultAuth
        let ovpnConfig = AppConstants.OpenVPNCrypto.ovpnConfig(cipher: cipher, auth: auth)

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

        return PIATunnelSharedState.OpenVPNSettings(
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
