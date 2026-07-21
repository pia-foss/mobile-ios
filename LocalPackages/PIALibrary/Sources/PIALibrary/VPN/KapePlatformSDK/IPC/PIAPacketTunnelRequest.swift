//
//  PIAPacketTunnelRequest.swift
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

/// IPC messages sent from the app (`KapePlatformSDKTunnelProfile`) to the PlatformSDK PacketTunnel
/// extension (`PIAPacketTunnelProvider`) via `NETunnelProviderSession.sendProviderMessage()`.
///
/// Mirrors the vendored SDK's own `KapePacketTunnelRequest`, but PIA-owned so PIALibrary — which
/// does not depend on any Kape module — can send it without a circular dependency on PIAVPN.
public enum PIAPacketTunnelRequest: String, Codable, Sendable {
    /// Switch the active session to whatever server is currently in `PIATunnelSharedState`,
    /// without tearing down the Network Extension process (unlike a `stopVPNTunnel()` +
    /// `startTunnel()` cycle).
    case switchLocation

    /// Query the extension for the active session's cumulative byte counters.
    /// The extension replies with a JSON-encoded `PIADataUsage` (or an empty
    /// response when nothing is connected / the protocol can't report usage).
    case dataUsage
}
