//
//  VPNDaemon.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

class VPNDaemon: Daemon, DatabaseAccess, ProvidersAccess {
    static let shared = VPNDaemon()

    private(set) var hasEnabledUpdates: Bool
    
    private init() {
        hasEnabledUpdates = false
    }
    
    func start() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(neStatusDidChange(notification:)), name: .NEVPNStatusDidChange, object: nil)

        accessedProviders.vpnProvider.prepare()
    }
    
    private func tryUpdateStatus(via connection: NEVPNConnection) {
        guard let profile = accessedDatabase.transient.activeVPNProfile else {
            return
        }
        if let _ = connection as? NETunnelProviderSession {
            guard profile.isTunnel else {
                return
            }
        } else {
            guard !profile.isTunnel else {
                return
            }
        }
        
        var nextStatus: VPNStatus = .disconnected
        
        switch connection.status {
        case .connected:
            nextStatus = .connected
            
        case .connecting, .reasserting:
            nextStatus = .connecting
            
        case .disconnecting:
            nextStatus = .disconnecting
            
        case .disconnected:
            nextStatus = .disconnected
            
        default:
            nextStatus = .disconnected
        }
        
        let previousStatus = accessedDatabase.transient.vpnStatus
        guard (nextStatus != previousStatus) else {
            return
        }
        accessedDatabase.transient.vpnStatus = nextStatus
    }
    
    // MARK: Notifications

    @objc private func neStatusDidChange(notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            fatalError("Missing NEVPNConnection object?")
        }
        DispatchQueue.main.async {
            self.tryUpdateStatus(via: connection)
        }
    }

//    @objc private func preferencesDidOutdateVPN(notification: Notification) {
//        let vpn = accessedProviders.vpnProvider
//        guard (accessedDatabase.transient.vpnStatus != .disconnected) else {
//            vpn.install(callback: nil)
//            return
//        }
//        accessedDatabase.transient.vpnStatus = .changingServer
//        vpn.reconnect(after: nil)
//    }
}
