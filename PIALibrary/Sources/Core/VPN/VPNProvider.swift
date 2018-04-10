//
//  VPNProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
     */
    func install(_ callback: SuccessLibraryCallback?)
    
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
     Reconnects to the VPN.

     - Parameter delay: The delay in milliseconds after which the reconnection is issue.
     - Parameter callback: Returns `nil` on success.
     */
    func reconnect(after delay: Int?, _ callback: SuccessLibraryCallback?)
    
    /**
     Submits the debug log associated with the current VPN connection.

     - Parameter callback: Returns the submitted `DebugLog` on success.
     */
    func submitLog(_ callback: LibraryCallback<DebugLog>?)
}

extension VPNProvider {

    /// Shortcut for `(vpnStatus == .connected)`.
    public var isVPNConnected: Bool {
        return (vpnStatus == .connected)
    }
}
