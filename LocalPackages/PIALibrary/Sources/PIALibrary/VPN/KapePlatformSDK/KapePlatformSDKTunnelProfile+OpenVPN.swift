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
    }

    /// Builds the OpenVPN settings from app-group UserDefaults.
    /// Throws if VPN credentials are unavailable.
    func openVPNSettings() throws -> OpenVPNSettings {
        let caCertificate = Client.configuration.rsa4096Certificate ?? ""

        guard
            let username = Client.providers.accountProvider.vpnTokenUsername,
            let password = Client.providers.accountProvider.vpnTokenPassword,
            !username.isEmpty, !password.isEmpty
        else {
            throw NSError(
                domain: "PIAVPNError", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "VPN credentials not available — token not yet refreshed"])
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

        return OpenVPNSettings(
            caCertificate: caCertificate,
            username: username,
            password: password,
            ovpnConfig: ovpnConfig,
            port: port,
            transport: transport,
            mtu: mtu)
    }
}
