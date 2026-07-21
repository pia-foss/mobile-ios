//
//  PIADataUsage.swift
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

/// Response payload for `PIAPacketTunnelRequest.dataUsage`, sent back by the
/// extension over `sendProviderMessage`. Kept separate from `Usage` because the
/// extension (PIAVPN) cannot construct `Usage` (its initializer is internal to
/// PIALibrary); the profile maps this into `Usage` on the app side.
///
/// The extension encodes the SDK's `PacketTunnelDataUsage` directly onto the
/// wire, so this type must stay key-compatible with it (`bytesReceived` /
/// `bytesSent`). PIALibrary declares its own copy because it depends only on
/// `TunnelKitPackage`, not the KapeVPN modules where `PacketTunnelDataUsage` lives.
public struct PIADataUsage: Codable, Sendable {
    public let bytesReceived: UInt64
    public let bytesSent: UInt64

    public init(bytesReceived: UInt64, bytesSent: UInt64) {
        self.bytesReceived = bytesReceived
        self.bytesSent = bytesSent
    }
}
