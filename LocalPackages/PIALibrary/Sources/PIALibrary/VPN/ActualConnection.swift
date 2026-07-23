//
//  ActualConnection.swift
//  PIALibrary
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

/// What the PlatformSDK tunnel is *actually* running this session, as reported by the tunnel — as
/// opposed to the user's selection. The whole value is `nil` when there is no active PlatformSDK
/// session (disconnected, or not running through the PlatformSDK tunnel). Individual fields are
/// `nil` when that dimension did not resolve (e.g. the protocol under "Automatic", or a server id
/// the app can't match). Callers fall back to the user's selection per field.
public struct ActualConnection {

    /// The VPN type the tunnel resolved — e.g. the protocol picked under "Automatic". `nil` when
    /// unresolved; fall back to the user-selected `currentVPNType`.
    public let vpnType: KapePlatformSDKVPNType?

    /// The `Server` the tunnel connected to — e.g. the fastest server resolved under "Automatic".
    /// `nil` when unresolved; fall back to the user-selected target server.
    public let server: Server?

    /// The concrete transport carrying the tunnel this session — the SDK-resolved UDP/TCP for
    /// OpenVPN, or `.udp` for WireGuard. Always present within an active session.
    public let transport: PIATunnelSharedState.VPNTransport

    public init(
        vpnType: KapePlatformSDKVPNType?,
        server: Server?,
        transport: PIATunnelSharedState.VPNTransport
    ) {
        self.vpnType = vpnType
        self.server = server
        self.transport = transport
    }
}
