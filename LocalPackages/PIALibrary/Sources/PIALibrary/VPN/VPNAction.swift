//
//  VPNAction.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/24/17.
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

/// Command pattern for prioritized and descriptive VPN operations.
@available(tvOS 17.0, *)
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

@available(tvOS 17.0, *)
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

@available(tvOS 17.0, *)
class VPNActionReinstall: VPNAction, ProvidersAccess {
    let priority = 20

    let canRetainConnection = true

    func execute(_ callback: SuccessLibraryCallback?) {
        let vpn = accessedProviders.vpnProvider
        let connected = accessedProviders.vpnProvider.isVPNConnected
        if connected {
            vpn.install(force: true, { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }
                callback?(nil)
            })
        } else {
            vpn.updatePreferences { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }
                callback?(nil)
            }
        }
    }
}

@available(tvOS 17.0, *)
class VPNActionDisconnectAndReinstall: VPNAction, ProvidersAccess {
    let priority = 30
    
    let canRetainConnection = false

    func execute(_ callback: SuccessLibraryCallback?) {
        let vpn = accessedProviders.vpnProvider
        vpn.install(force: true, { (error) in
            if let _ = error {
                callback?(error)
                return
            }
            guard (vpn.vpnStatus != .disconnected) else {
                callback?(nil)
                return
            }
            vpn.connect(callback)
        })
    }
}
