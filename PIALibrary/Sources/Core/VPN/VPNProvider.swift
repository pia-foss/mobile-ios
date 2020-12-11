//
//  VPNProvider.swift
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

/// Business interface related to the VPN connection.
public protocol VPNProvider: class {

    /// The available VPN types.
    ///
    /// - Seealso: `VPNProfile.vpnType`
    var availableVPNTypes: [String] { get }

    /// The current VPN type to determine the `VPNProfile` that this provider controls.
    ///
    /// - Seealso: `VPNProfile.vpnType`
    var currentVPNType: String { get }
    
    /// The `VPNStatus` of the current profile.
    var vpnStatus: VPNStatus { get }

    /// The `Server` associated with the current profile.
    var profileServer: Server? { get }
    
    /**
     Prepares the provider for VPN operations. Normally invoked when initializing the library.
     */
    func prepare()

    /**
     Installs the profile as per `currentVPNType`.
     
     - Parameter callback: Returns `nil` on success.
     - Parameter forceInstall: Force the install of the profile.
     */
    func install(force forceInstall: Bool, _ callback: SuccessLibraryCallback?)
    
    /**
     Disables the current profile.

     - Parameter callback: Returns `nil` on success.
     */
    func disable(_ callback: SuccessLibraryCallback?)

    /**
     Uninstalls the current profile.
     
     - Parameter callback: Returns `nil` on success.
     */
    func uninstall(_ callback: SuccessLibraryCallback?)

    /**
     Uninstalls all profiles, known as per `availableVPNTypes`.
     */
    func uninstallAll()

    /**
     Connects to the VPN.

     - Parameter callback: Returns `nil` on success.
     */
    func connect(_ callback: SuccessLibraryCallback?)

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
     Reconnects to the VPN.

     - Parameter delay: The delay in milliseconds after which the reconnection is issue.
     - Parameter forceDisconnect: Boolean to indicate if we want to disconnect the VPN before reconnect..
     - Parameter callback: Returns `nil` on success.
     */
    func reconnect(after delay: Int?, forceDisconnect: Bool, _ callback: SuccessLibraryCallback?)
    
    /**
     Submits the debug report containing all relevant information foor the current session.
     
     - Parameter shouldSendPersistedData: Specifies whether to send the user persisted data along with the report.
     - Parameter callback: Returns the report identifier  on success.
     */
    func submitDebugReport(_ shouldSendPersistedData: Bool, _ callback: LibraryCallback<String>?)
    
    /**
     Submits the usage information associated with the current VPN connection.
     
     - Parameter callback: Returns the `Usage` information on success.
     */
    func dataUsage(_ callback: LibraryCallback<Usage>?)
    
    /**
     Check if the VPN profile needs to be migrated to GEN4.
     - Precondition: isVPNConnected == true
     - Returns: `Bool`
     */
    func needsMigrationToGEN4() -> Bool
    
}

public extension VPNProvider {
    public func reconnect(after delay: Int?, forceDisconnect: Bool = false, _ callback: SuccessLibraryCallback?) {
        return reconnect(after: delay, forceDisconnect: forceDisconnect, callback)
    }
}

extension VPNProvider {

    /// Shortcut for `(vpnStatus == .connected)`.
    public var isVPNConnected: Bool {
        return (vpnStatus == .connected)
    }
}
