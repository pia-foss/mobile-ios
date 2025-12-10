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
public protocol VPNProfile: class {

    /// An unique string associated with this kind of profiles.
    static var vpnType: String { get }

    /// Returns `true` if the profile is a custom tunnel implementation.
    static var isTunnel: Bool { get }

    /// The identifier of the `Server` associated with this profile, if any.
    var serverIdentifier: String? { get }

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
     - Parameter callback: Returns `nil` on success.
     */
    func save(withConfiguration configuration: VPNConfiguration, force: Bool, _ callback: SuccessLibraryCallback?)
    
    /**
     Connects the VPN via this profile with a specified configuration, which is saved right before the connection attempt.
     
     - Parameter configuration: The `VPNConfiguration` to commit.
     - Parameter callback: Returns `nil` on success.
     - Seealso: `VPNProfile.save(...)`
     */
    func connect(withConfiguration configuration: VPNConfiguration, _ callback: SuccessLibraryCallback?)
    
    /**
     Disconnects from the VPN.
     
     - Parameter callback: Returns `nil` on success.
     */
    func disconnect(_ callback: SuccessLibraryCallback?)
    
    /**
     Update preferences from the VPN.
     
     - Parameter callback: Returns `nil` on success.
     */
    func updatePreferences(_ callback: SuccessLibraryCallback?)
    
    /**
     Removes the profile from the device.
     
     - Parameter callback: Returns `nil` on success.
     */
    func remove(_ callback: SuccessLibraryCallback?)

    /**
     Disables the profile.
     
     - Parameter callback: Returns `nil` on success.
     */
    func disable(_ callback: SuccessLibraryCallback?)

    /**
     Returns a concrete `VPNCustomConfiguration` from a map of raw parameters.
     
     - Parameter map: A set of raw parameters of the custom configuration.
     - Returns: A high-level `VPNCustomConfiguration` object or `nil` if the map doesn't represent a custom configuration for this profile.
     */
    func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration?

    /**
     Requests a log from this profile.
     
     - Parameter customConfiguration: The optional `VPNCustomConfiguration` required to access the debug log.
     - Parameter callback: Returns `ClientError.unsupported` if the profile doesn't support logging.
     */
    func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: LibraryCallback<String>?)
    
    /**
     Requests the data usage from this profile.
     
     - Parameter customConfiguration: The optional `VPNCustomConfiguration` required to access the debug log.
     - Parameter callback: Returns `ClientError.unsupported` if the profile doesn't support logging.
     */
    func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: LibraryCallback<Usage>?)

}

extension VPNProfile {
    var vpnType: String {
        return type(of: self).vpnType
    }

    var isTunnel: Bool {
        return type(of: self).isTunnel
    }
}
