//
//  KapePlatformSDKTunnelProfile+WireGuard.swift
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
    /// Resolved WireGuard parameters written into `PIATunnelSharedState.State`.
    struct WireGuardSettings {
        let mtu: UInt16
        /// Key-exchange token used by `PIAWireguardAuthenticator`: the account `vpnToken` for a
        /// regular server, or the server's `dipUsername` for a Dedicated IP server.
        let token: String?
        /// User-selected custom DNS resolvers; empty → keep the server-provided resolvers.
        let dnsServers: [String]
    }

    /// Builds the WireGuard settings from the small-packets toggle in app-group UserDefaults,
    /// resolving the key-exchange token from the target server (DIP vs account token).
    func wireGuardSettings(for server: Server) -> WireGuardSettings {
        let useSmallPackets = sharedDefaults.bool(forKey: AppConstants.UserDefaultsKeys.WireGuard.useSmallPackets)
        let mtu = UInt16(useSmallPackets ? AppConstants.WireGuardPacketSize.defaultPacketSize : AppConstants.WireGuardPacketSize.highPacketSize)

        // DIP uses `dipUsername` as the WireGuard token (mirrors PIAWGTunnelProfile).
        let token = server.dipToken != nil ? server.dipUsername : Client.providers.accountProvider.vpnToken
        let dnsServers = customDnsServers(forVPNType: .wireGuard)

        return WireGuardSettings(
            mtu: mtu,
            token: token,
            dnsServers: dnsServers
        )
    }
}
