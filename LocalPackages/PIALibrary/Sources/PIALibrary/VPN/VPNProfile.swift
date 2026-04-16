//
//  VPNProfile.swift
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

/// Abstract representation of a VPN profile, which is the typical VPN entity on Apple platforms. This entity is meant for advanced use, it's suggested to use a `VPNProvider` to control a VPN connection.
public protocol VPNProfile: AnyObject {

    /// An unique string associated with this kind of profiles.
    static var vpnType: String { get }

    /// Returns `true` if the profile is a custom tunnel implementation.
    static var isTunnel: Bool { get }

    /// The IP address associated with this profile, if any.
    var serverAddress: String? { get }

    /// The underlying native profile implementation.
    var native: Any? { get }

    /**
     Prepares the profile for use, like synchronizing with the current VPN status and making sure that the profile is not corrupt.
     */
    func prepare()

    /**
     Saves the profile to the device with a new configuration.

     - Parameter configuration: The `VPNConfiguration` to commit.
     - Parameter force: If `true`, it will enforce the save operation.
     */
    func save(withConfiguration configuration: VPNConfiguration, force: Bool) async throws

    /**
     Connects the VPN via this profile with a specified configuration, which is saved right before the connection attempt.

     - Parameter configuration: The `VPNConfiguration` to commit.
     - Seealso: `VPNProfile.save(...)`
     */
    func connect(withConfiguration configuration: VPNConfiguration) async throws

    /**
     Disconnects from the VPN.
     */
    func disconnect() async throws

    /**
     Update preferences from the VPN.
     */
    func updatePreferences() async throws

    /**
     Removes the profile from the device.
     */
    func remove() async throws

    /**
     Disables the profile.
     */
    func disable() async throws

    /**
     Returns a concrete `VPNCustomConfiguration` from a map of raw parameters.

     - Parameter map: A set of raw parameters of the custom configuration.
     - Returns: A high-level `VPNCustomConfiguration` object or `nil` if the map doesn't represent a custom configuration for this profile.
     */
    func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration?

    /**
     Requests a log from this profile.

     - Parameter customConfiguration: The optional `VPNCustomConfiguration` required to access the debug log.
     - Returns: The log string.
     */
    func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> String

    /**
     Requests the data usage from this profile.

     - Parameter customConfiguration: The optional `VPNCustomConfiguration` required to access the data usage.
     - Returns: The `Usage` value.
     */
    func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> Usage

}

extension VPNProfile {
    var vpnType: String {
        return type(of: self).vpnType
    }

    var isTunnel: Bool {
        return type(of: self).isTunnel
    }
}
