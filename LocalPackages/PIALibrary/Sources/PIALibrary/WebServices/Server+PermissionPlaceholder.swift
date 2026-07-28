//
//  Server+PermissionPlaceholder.swift
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

extension Server {

    /// Placeholder server used exclusively to obtain the one-time OS VPN permission
    /// (`NEVPNManager.saveToPreferences()`) when the real server list has not been
    /// downloaded yet — e.g. right after a fresh signup, when logout wiped the cache.
    ///
    /// The saved configuration is inert: `connect()` always re-resolves the real
    /// `targetServer` and re-saves the profile before starting the tunnel, so this
    /// endpoint is never actually dialed.
    ///
    /// The hostname uses the RFC 6761 reserved `.invalid` TLD: it can never resolve
    /// and never collides with PIA-domain checks such as `needsMigrationToGEN4()`.
    /// Computed (not `static let`) because `Server` is a mutable class — each access
    /// returns a fresh instance instead of a shared, mutable process-wide one.
    static var vpnPermissionPlaceholder: Server {
        Server(
            serial: "",
            name: "VPN Permission Placeholder",
            country: "us",
            hostname: "vpn-permission-placeholder.invalid",
            pingAddress: nil,
            regionIdentifier: "vpn-permission-placeholder"
        )
    }
}
