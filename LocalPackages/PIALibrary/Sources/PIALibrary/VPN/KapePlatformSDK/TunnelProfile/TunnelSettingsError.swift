//
//  TunnelSettingsError.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 26.08.26.
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

/// Failures that prevent building a protocol's connection settings for a server.
///
/// Whether one of these aborts the connect is decided by the caller, not by the builder that throws
/// it: `KapePlatformSDKTunnelProfile.writeSharedState` rethrows only when the failing protocol is the
/// one the user selected. Under `.automatic` a single unavailable protocol just narrows the fan-out.
public enum TunnelSettingsError: LocalizedError, Equatable {
    /// A Dedicated IP server is missing the per-server identity this protocol authenticates with —
    /// the resolvable IP used as the OpenVPN password, or the `dipUsername` used as the WireGuard token.
    case dedicatedIPUnavailable(protocol: PIATunnelSharedState.TunnelProtocol, serverIdentifier: String)

    /// The account VPN token hasn't been refreshed yet, or isn't in the form this protocol needs —
    /// OpenVPN splits it into `user:pass`, WireGuard uses it whole.
    case credentialsUnavailable(protocol: PIATunnelSharedState.TunnelProtocol)

    /// Neither protocol could be built, so there is nothing for the tunnel to attempt.
    case noProtocolAvailable

    public var errorDescription: String? {
        switch self {
        case .dedicatedIPUnavailable(let proto, let serverIdentifier):
            return "Dedicated IP credentials not available for \(serverIdentifier) (\(proto.rawValue))"
        case .credentialsUnavailable(let proto):
            return "VPN credentials not available for \(proto.rawValue) — token not yet refreshed"
        case .noProtocolAvailable:
            return "No VPN protocol has usable credentials"
        }
    }
}
