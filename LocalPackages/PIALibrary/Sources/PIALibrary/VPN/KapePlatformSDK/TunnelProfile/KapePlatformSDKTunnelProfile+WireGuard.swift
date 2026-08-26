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
    /// Builds the WireGuard settings from the small-packets toggle in app-group UserDefaults,
    /// resolving the key-exchange token from the target server (DIP vs account token).
    /// Throws if no token is available.
    func wireGuardSettings(for server: Server) throws(TunnelSettingsError) -> PIATunnelSharedState.WireGuardSettings {
        // "Use Small Packets" is a single user-facing setting shared with OpenVPN.
        let useSmallPackets = sharedDefaults.bool(forKey: AppConstants.UserDefaultsKeys.useSmallPackets)
        let mtu = UInt16(useSmallPackets ? AppConstants.WireGuardPacketSize.defaultPacketSize : AppConstants.WireGuardPacketSize.highPacketSize)

        // DIP uses `dipUsername` as the WireGuard token (mirrors PIAWGTunnelProfile). A DIP server
        // without one must fail rather than fall through to the account token: the extension would
        // otherwise authenticate against a DIP endpoint with account credentials.
        let token: String
        if server.dipToken != nil {
            guard let dipUsername = server.dipUsername, !dipUsername.isEmpty else {
                throw .dedicatedIPUnavailable(protocol: .wireGuard, serverIdentifier: server.identifier)
            }
            token = dipUsername
        } else {
            guard let accountToken = Client.providers.accountProvider.vpnToken, !accountToken.isEmpty else {
                throw .credentialsUnavailable(protocol: .wireGuard)
            }
            token = accountToken
        }

        let dnsServers = customDnsServers(forVPNType: .wireGuard)

        return PIATunnelSharedState.WireGuardSettings(
            mtu: mtu,
            token: token,
            dnsServers: dnsServers
        )
    }
}
