//
//  VPNStatus.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2020 Private Internet Access, Inc.
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
import NetworkExtension

/// The status of a VPN connection.
public enum VPNStatus: String {

    /// The VPN is establishing a connection.
    case connecting

    /// The VPN is connected.
    case connected

    /// The VPN is disconnecting.
    case disconnecting

    /// The VPN is disconnected.
    case disconnected

    /// Unknown.
    case unknown

    //    case changingServer
}

extension VPNStatus {

    /// The single place that resolves the app's connection status from the two authoritative
    /// signals feeding it:
    ///
    /// - `system` — the OS-level `NEVPNStatus`. It owns whether the tunnel *exists*: bring-up and,
    ///   crucially, teardown (a crashed/killed extension can't report `.disconnected`, so this is the
    ///   safety net).
    /// - `tunnel` — the PlatformSDK extension's reported `TunnelStatus`, or `nil` for legacy
    ///   protocols and before the tunnel has reported anything. It adds the nuance `NEVPNStatus`
    ///   can't express: an in-place region switch / mid-session reconnect keeps `NEVPNStatus` at
    ///   `.connected` while the tunnel is really re-establishing.
    ///
    /// So `tunnel` is consulted only while `system` is `.connected` — layering `.connecting` over an
    /// otherwise-connected tunnel, never contradicting the OS about whether the tunnel is there.
    /// With `tunnel == nil` this collapses to a pure `NEVPNStatus` mapping (the legacy path).
    ///
    /// PIA-owned mirror of the SDK's `KapeVPNStatusPublisher.resolveStatus`, kept here so PIALibrary
    /// needs no Kape dependency.
    public static func resolve(system: NEVPNStatus, tunnel: PIATunnelSharedState.TunnelStatus?) -> VPNStatus {
        switch system {
        case .connected:
            switch tunnel {
            case .connecting, .reconnecting, .paused: return .connecting
            case .connected, .disconnecting, .disconnected, .none: return .connected
            }
        case .connecting, .reasserting:
            return .connecting
        case .disconnecting:
            return .disconnecting
        case .disconnected, .invalid:
            return .disconnected
        @unknown default:
            return .disconnected
        }
    }
}
