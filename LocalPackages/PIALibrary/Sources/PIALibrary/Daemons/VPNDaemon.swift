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

@available(tvOS 17.0, *)
class VPNDaemon: Daemon, DatabaseAccess, ProvidersAccess {
    static let shared = VPNDaemon()

    private(set) var hasEnabledUpdates: Bool
    private var fallbackTimer: Timer!
    private var numberOfAttempts: Int
    private var isReconnecting: Bool
    
    private var lastKnownVpnStatus: VPNStatus = .disconnected
    
    private init() {
        hasEnabledUpdates = false
        isReconnecting = false
        numberOfAttempts = 0
    }
    
    func start() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(neStatusDidChange(notification:)), name: .NEVPNStatusDidChange, object: nil)

        accessedProviders.vpnProvider.prepare()
        if Client.providers.vpnProvider.isVPNConnected {
            self.lastKnownVpnStatus = .connected
        }
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
            Client.preferences.timeToConnectVPN = Date().timeIntervalSince1970 - Client.preferences.lastVPNConnectionAttempt
            
            let previousStatus = accessedDatabase.transient.vpnStatus
            
            guard (nextStatus != previousStatus) else {
                return
            }

            Client.preferences.lastVPNConnectionSuccess = Date().timeIntervalSince1970
            invalidateTimer()
            reset()
            
            if self.lastKnownVpnStatus == .disconnected, Client.preferences.shareServiceQualityData {
                ServiceQualityManager.shared.connectionEstablishedEvent()
                self.lastKnownVpnStatus = .connected
            }
            
            //Connection successful, the user interaction finished
            Client.configuration.connectedManually = false
            
        case .connecting, .reasserting:
            
            nextStatus = .connecting
            Client.preferences.lastVPNConnectionAttempt = Date().timeIntervalSince1970
            
            if accessedDatabase.transient.vpnStatus == .disconnected,
               self.lastKnownVpnStatus == .disconnected,
               Client.preferences.shareServiceQualityData,
               self.numberOfAttempts == 0 {
                ServiceQualityManager.shared.connectionAttemptEvent()
            }

            if fallbackTimer == nil {
                
                fallbackTimer = Timer.scheduledTimer(withTimeInterval: Client.configuration.vpnConnectivityRetryDelay, repeats: true) { timer in
                    let address = Client.providers.serverProvider.targetServer.bestAddress()
                    address?.markServerAsUnavailable()
                    
                    log.debug("NEVPNManager is still connecting. Reconnecting with a different server...")
                    self.numberOfAttempts += 1
                    if self.numberOfAttempts < Client.configuration.vpnConnectivityMaxAttempts {
                        self.updateUIWithAttemptNumber(self.numberOfAttempts)
                        self.isReconnecting = true
                        Client.providers.vpnProvider.reconnect(after: 0, { _ in
                            self.isReconnecting = false
                        })
                    } else {
                        log.debug("MAX number of VPN reconnections. Disconnecting...")
                        Client.providers.vpnProvider.disconnect({ error in
                            Macros.postNotification(.PIAVPNDidFail)
                            self.reset()
                            self.invalidateTimer()
                        })
                    }
                }
                
            }

        case .disconnecting:
            nextStatus = .disconnecting
        case .disconnected:
            nextStatus = .disconnected
            
            let previousStatus = accessedDatabase.transient.vpnStatus
            
            guard (nextStatus != previousStatus) else {
                return
            }

            if !isReconnecting {
                invalidateTimer()
                reset()
            }
            
            //triggered only when the user is manually aborting connection (before being established).
            if Client.configuration.disconnectedManually {
                
                if self.lastKnownVpnStatus != .connected,
                   (previousStatus == .connecting || previousStatus == .disconnecting),
                   Client.preferences.shareServiceQualityData {
                    ServiceQualityManager.shared.connectionCancelledEvent()
                }

                //VPN disconnected, the user interaction finished. Only reset the value when the source was manual.
                Client.configuration.disconnectedManually = false

            }

            Client.preferences.lastVPNConnectionSuccess = nil
            self.lastKnownVpnStatus = .disconnected

        default:
            nextStatus = .disconnected
        }
        
        let previousStatus = accessedDatabase.transient.vpnStatus
        guard (nextStatus != previousStatus) else {
            return
        }
        
        accessedDatabase.plain.lastKnownVpnStatus = nextStatus
        
        if !isReconnecting {
            accessedDatabase.transient.vpnStatus = nextStatus
        }
        
        if let error = connection.value(forKey: "_lastDisconnectError") as? NSError {
            if error.description.contains("Domain=TunnelKit.OpenVPNTunnelProvider.ProviderConfigurationError Code=0") {
                Client.providers.vpnProvider.reconnect(after: nil, forceDisconnect: true, nil)
                return
            } else {
                if previousStatus == .connecting {
                    log.error("The VPN did fail \(error)")
                    Macros.postNotification(.PIAVPNDidFail)
                }
            }
        }

    }
    
    // MARK: Invalidate
    private func invalidateTimer() {
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }
    
    // MARK: Reset
    
    private func reset() {
        self.isReconnecting = false
        self.numberOfAttempts = 0
        self.updateUIWithAttemptNumber(0)
        Client.providers.serverProvider.targetServer.addresses().forEach({$0.reset()})
    }
    
    // MARK: Update UI
    
    private func updateUIWithAttemptNumber(_ number: Int) {
        NotificationCenter.default.post(name: .PIADaemonsConnectingVPNStatus, object: number)
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
