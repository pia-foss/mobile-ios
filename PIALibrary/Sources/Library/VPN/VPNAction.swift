//
//  VPNAction.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/24/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Command pattern for prioritized and descriptive VPN operations.
public protocol VPNAction {

    /// The priority to order this action against.
    var priority: Int { get }

    /// If `true`, this action doesn't require the VPN to be restarted.
    var canRetainConnection: Bool { get }
    
    /**
     Executes the action and potentially kills the active VPN connection.

     - Parameter callback: Returns `nil` on success.
     - Seealso: `canRetainConnection`
     */
    func execute(_ callback: SuccessLibraryCallback?)
}

class VPNActionReconnect: VPNAction, ProvidersAccess {
    let priority = 10
    
    let canRetainConnection = true
    
    func execute(_ callback: SuccessLibraryCallback?) {
        let vpn = accessedProviders.vpnProvider
        guard (vpn.vpnStatus != .disconnected) else {
            callback?(nil)
            return
        }
        vpn.reconnect(after: nil, callback)
    }
}

class VPNActionReinstall: VPNAction, ProvidersAccess {
    let priority = 20

    let canRetainConnection = true

    func execute(_ callback: SuccessLibraryCallback?) {
        let vpn = accessedProviders.vpnProvider
        vpn.install { (error) in
            if let _ = error {
                callback?(error)
                return
            }
            callback?(nil)
        }
    }
}

class VPNActionDisconnectAndReinstall: VPNAction, ProvidersAccess {
    let priority = 30
    
    let canRetainConnection = false

    func execute(_ callback: SuccessLibraryCallback?) {
        let vpn = accessedProviders.vpnProvider
        vpn.install { (error) in
            if let _ = error {
                callback?(error)
                return
            }
            guard (vpn.vpnStatus != .disconnected) else {
                callback?(nil)
                return
            }
            vpn.reconnect(after: nil, callback)
        }
    }
}
