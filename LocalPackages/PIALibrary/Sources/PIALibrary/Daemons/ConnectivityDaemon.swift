//
//  ConnectivityDaemon.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/12/17.
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
import Reachability
import SwiftyBeaver

private let log = SwiftyBeaver.self

public extension Notification.Name {
    static let ConnectivityDaemonDidGetReachable = Notification.Name("ConnectivityDaemonDidGetReachable")

    static let ConnectivityDaemonDidGetUnreachable = Notification.Name("ConnectivityDaemonDidGetUnreachable")
}

@available(tvOS 17.0, *)
class ConnectivityDaemon: Daemon, ConfigurationAccess, DatabaseAccess, PreferencesAccess, WebServicesAccess {
    static let shared = ConnectivityDaemon()
    
    private(set) var hasEnabledUpdates: Bool
    
    private let reachability: Reachability
    
    private var isCheckingConnectivity: Bool
    
    private var failedConnectivityAttempts: Int
    
    private var wasConnected: Bool

    private init() {
        hasEnabledUpdates = false

        guard let reachability = Reachability(hostname: "8.8.8.8") else {
            fatalError("Unable to create Reachability object")
        }
        self.reachability = reachability

        isCheckingConnectivity = false
        failedConnectivityAttempts = 0
        wasConnected = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func start() {
        wasConnected = (accessedDatabase.transient.vpnStatus == .connected)

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        startReachability()
    }
    
    func enableUpdates() {
        guard !hasEnabledUpdates else {
            return
        }
        hasEnabledUpdates = true

        checkConnectivityOrRetry()
    }

    private func startReachability() {
        log.debug("Configuring for reachability...")
        accessedDatabase.transient.isNetworkReachable = (reachability.connection != .none)
        log.debug("Initial network state is \(accessedDatabase.transient.isNetworkReachable ? "REACHABLE" : "NOT REACHABLE")")

        reachability.whenReachable = { (reach) in
            DispatchQueue.main.async {
                guard !self.accessedDatabase.transient.isNetworkReachable else {
                    if (self.accessedDatabase.transient.vpnStatus != .connected) {
                        self.checkConnectivityOrRetry()
                    }
                    return
                }
                log.debug("Network is now REACHABLE")
                self.handleReachable()
                Macros.postNotification(.ConnectivityDaemonDidGetReachable)
            }
        }
        reachability.whenUnreachable = { (reach) in
            DispatchQueue.main.async {
                guard self.accessedDatabase.transient.isNetworkReachable else {
                    return
                }
                log.debug("Network is now NOT REACHABLE")
                self.handleUnreachable()
                Macros.postNotification(.ConnectivityDaemonDidGetUnreachable)
            }
        }
        try? reachability.startNotifier()

        log.debug("Reachability notifier started")
    }

    @objc private func checkConnectivityOrRetry() {
        guard hasEnabledUpdates else {
            return
        }
        guard !isCheckingConnectivity else {
            return
        }

        log.debug("Checking network connectivity...")
        accessedDatabase.transient.vpnIP = nil
        Macros.postNotification(.PIADaemonsDidUpdateConnectivity)

        isCheckingConnectivity = true
        accessedWebServices.taskForConnectivityCheck { (connectivity, error) in
            self.isCheckingConnectivity = false

            guard let connectivity = connectivity else {
                self.failedConnectivityAttempts += 1
                log.error("Failed to check network connectivity (error: \(error?.localizedDescription ?? "")")
            
                guard (self.failedConnectivityAttempts < self.accessedConfiguration.connectivityMaxAttempts) else {
                    log.debug("Giving up, network is unreachable")
                    self.failedConnectivityAttempts = 0
                    self.accessedDatabase.transient.isInternetReachable = false
                    Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
                    return
                }

                let delay = self.accessedConfiguration.connectivityRetryDelay
                log.debug("Retrying network connectivity in \(delay) milliseconds...")
                Macros.dispatch(after: .milliseconds(delay)) {
                    self.checkConnectivityOrRetry()
                }

                return
            }
            
            self.failedConnectivityAttempts = 0
            self.accessedDatabase.transient.isInternetReachable = true
            log.debug("Saving new info about network connectivity: \(connectivity)")

            let ipAddress = connectivity.ipAddress
            if connectivity.isVPN {
                self.accessedDatabase.transient.vpnIP = ipAddress
                log.debug("VPN IP -> \(ipAddress)")
            } else {
                self.accessedDatabase.plain.publicIP = ipAddress
                log.debug("Public IP -> \(ipAddress)")
            }
            
            Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
        }
    }

    // MARK: Notifications
   
    @objc private func vpnStatusDidChange(notification: Notification) {
        switch accessedDatabase.transient.vpnStatus {
        case .connected:
            if accessedPreferences.mace {
                invokeMACERequest()
            }
            handleVPNDidConnect()
            wasConnected = true

        case .disconnected:
            guard wasConnected else {
                return
            }
            handleVPNDidDisconnect()
            wasConnected = false

        default:
            break
        }
    }
    
    private func handleReachable() {
        accessedDatabase.transient.isNetworkReachable = true
        if hasEnabledUpdates {
            if (accessedDatabase.transient.vpnStatus != .connected) {
                checkConnectivityOrRetry()
            }
        }
    }
    
    private func handleUnreachable() {
        accessedDatabase.transient.isNetworkReachable = false
    }
    
    // XXX: VPN status doesn't seem to be immediately ready for connectivity checks
    
    private func handleVPNDidConnect() {
        if hasEnabledUpdates {
            let delay = accessedConfiguration.connectivityVPNLag
            Macros.dispatch(after: .milliseconds(delay)) {
                self.checkConnectivityOrRetry()
            }
        }
    }
    
    private func handleVPNDidDisconnect() {
        if hasEnabledUpdates {
            accessedDatabase.transient.vpnIP = nil
            let delay = accessedConfiguration.connectivityVPNLag
            Macros.dispatch(after: .milliseconds(delay)) {
                self.checkConnectivityOrRetry()
            }
        }
    }
    
    // MARK: MACE
    
    private func invokeMACERequest() {
        log.debug("MACE: Enabling PIA ad-blocking...")
        
        enableMACE()
        Macros.dispatch(after: .milliseconds(accessedConfiguration.maceDelay)) {
            self.enableMACE()
        }
    }
    
    private func enableMACE() {
        rawEnableMACE { (time) in
            guard let time = time else {
                log.error("MACE: Failed to enable")
                return
            }
            log.debug("MACE: Successfully enabled in \(time)ms")
        }
    }
    
    private func rawEnableMACE(completionHandler: ((Int?) -> Void)?) {
        let background = DispatchQueue.global(qos: .background)
        
        background.async {
            guard let pingTime = Macros.ping(
                withProtocol: .TCP,
                hostname: self.accessedConfiguration.maceHostname,
                port: self.accessedConfiguration.macePort) else {
                
                completionHandler?(nil)
                return
            }
            completionHandler?(pingTime)
        }
    }
}
