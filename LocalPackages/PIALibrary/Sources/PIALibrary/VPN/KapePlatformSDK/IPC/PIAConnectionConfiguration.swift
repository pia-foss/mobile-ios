//
//  PIAConnectionConfiguration.swift
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

/// One endpoint the tunnel will attempt, as reported by
/// `PIAPacketTunnelRequest.connectionConfigurations`. The array's order is the attempt order —
/// Automatic's pecking order, or the pinned protocol's fan-out.
///
/// A PIA-owned mirror of the SDK's `PacketTunnelConnectedEndpoint`, for the same reason
/// `PIADataUsage` exists: PIALibrary depends only on `TunnelKitPackage`, not the KapeVPN modules
/// where that type lives.
public struct PIAConnectionConfiguration: Codable, Equatable, Sendable {
    /// The SDK's `protocolDescription`, e.g. `"WireGuard"`, `"WireGuard+Amnezia"`, `"openvpn-udp"`.
    public let vpnProtocol: String
    public let host: String
    public let port: UInt16

    public init(vpnProtocol: String, host: String, port: UInt16) {
        self.vpnProtocol = vpnProtocol
        self.host = host
        self.port = port
    }
}
