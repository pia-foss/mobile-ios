//
//  VPNConfiguration.swift
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

/// Abstract representation of a standard VPN configuration.
public struct VPNConfiguration {

    /// The name of this configuration.
    public let name: String
    
    /// The username for authentication.
    public let username: String

    /// The password reference in the keychain.
    public let passwordReference: Data

    /// The `Server` to connect to.
    public let server: Server

    /// When `true`, the VPN will connect on demand.
    public let isOnDemand: Bool

    /// When `true`, the VPN will disconnect on device sleep.
    public let disconnectsOnSleep: Bool

    /// An optional custom configuration.
    ///
    /// - Seealso: `VPNCustomConfiguration`
    public let customConfiguration: VPNCustomConfiguration?
    
    /// When `true`, the VPN will enable leak protection. 
    public let leakProtection: Bool
    
    /// When `true`, the VPN will enable access to local.
    public let allowLocalDeviceAccess: Bool
}

/// Holds the configuration parameters of a custom VPN profile.
///
/// - Seealso: `VPNProfile`
public protocol VPNCustomConfiguration {

    /**
     Returns a dictionary representation of this configuration.

     - Returns: A hash map with the raw parameters of this configuration.
     */
    func serialized() -> [String: Any]
    
    /// :nodoc:
    func isEqual(to: VPNCustomConfiguration) -> Bool
}
