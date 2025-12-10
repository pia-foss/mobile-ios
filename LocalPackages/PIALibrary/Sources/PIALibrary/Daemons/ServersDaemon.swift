//
//  ServersDaemon.swift
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
import SwiftyBeaver
import UIKit

private let log = SwiftyBeaver.self

@available(tvOS 17.0, *)
class ServersDaemon: Daemon, ConfigurationAccess, DatabaseAccess, ProvidersAccess {
    static let shared = ServersDaemon()
    
    private(set) var hasEnabledUpdates: Bool

    private(set) var updating: Bool

    private var lastUpdateDate: Date?
    
    private var lastPingDate: Date?
    
    private var pendingUpdateTimer: DispatchSourceTimer?

    private init() {
        hasEnabledUpdates = false
        updating = false
    }
    
    func start() {
        let nc = NotificationCenter.default
        #if os(iOS)
        nc.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        #endif
        nc.addObserver(self, selector: #selector(handleReachable), name: .ConnectivityDaemonDidGetReachable, object: nil)
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
    }

    func enableUpdates() {
        guard !hasEnabledUpdates else {
            return
        }
        hasEnabledUpdates = true

        checkOutdatedServers()
    }
    
    func forceUpdates(completionBlock: @escaping (Error?) -> Void) {
        guard !hasEnabledUpdates else {
            return
        }
        hasEnabledUpdates = true
        let pollInterval = accessedDatabase.transient.serversConfiguration.pollInterval
        accessedProviders.serverProvider.download { (servers, error) in
            self.lastUpdateDate = Date()
            log.debug("Servers updated on \(self.lastUpdateDate!), will repeat in \(pollInterval) milliseconds")
            self.scheduleServersUpdate(withDelay: pollInterval)
            
            guard let servers = servers else {
                if let error = error as? ClientError, error == ClientError.noRegions {
                    self.pingIfOffline(servers: Client.providers.serverProvider.currentServers)
                }
                completionBlock(error)
                return
            }
            self.pingIfOffline(servers: servers)
            completionBlock(error)
        }

    }
    
    func reset() {
        lastUpdateDate = nil
        lastPingDate = nil
        hasEnabledUpdates = false
    }

    @objc private func checkOutdatedServers() {
        
        if updating {
            return
        }
                
        let pollInterval = accessedDatabase.transient.serversConfiguration.pollInterval
        log.debug("Poll interval is \(pollInterval)")
            
        if let lastUpdateDate = lastUpdateDate {
            let elapsed = Int(-lastUpdateDate.timeIntervalSinceNow * 1000.0)
            guard (elapsed >= pollInterval) else {
                let leftDelay = pollInterval - elapsed
                log.debug("Elapsed \(elapsed) milliseconds (< \(pollInterval)) since last update (\(lastUpdateDate)), retrying in \(leftDelay) milliseconds...")
                
                scheduleServersUpdate(withDelay: leftDelay)
                return
            }
        } else {
            log.debug("Never updated so far, updating now...")
        }

        guard accessedDatabase.transient.isNetworkReachable else {
            let delay = accessedConfiguration.serversUpdateWhenNetworkDownDelay
            log.debug("Not updating when network is down, retrying in \(delay) milliseconds...")
            scheduleServersUpdate(withDelay: delay)
            return
        }
        
        updating = true
        accessedProviders.serverProvider.download { (servers, error) in
            self.updating = false
            self.lastUpdateDate = Date()
            log.debug("Servers updated on \(self.lastUpdateDate!), will repeat in \(pollInterval) milliseconds")
            self.scheduleServersUpdate(withDelay: pollInterval)
            
            guard let servers = servers else {
                if let error = error as? ClientError, error == ClientError.noRegions {
                    self.pingIfOffline(servers: Client.providers.serverProvider.currentServers)
                }
                return
            }
            self.pingIfOffline(servers: servers)
        }
    }
    
    private func scheduleServersUpdate(withDelay delay: Int) {
        pendingUpdateTimer?.cancel()
        pendingUpdateTimer = DispatchSource.makeTimerSource(flags: .strict, queue: .main)
        pendingUpdateTimer?.schedule(
            deadline: DispatchTime.now() + .milliseconds(delay),
            repeating: .never
        )
        pendingUpdateTimer?.setEventHandler {
            self.checkOutdatedServers()
        }
        pendingUpdateTimer?.resume()
    }
    
    private func pingIfOffline(servers: [Server]) {
        guard accessedConfiguration.enablesServerPings else {
            return
        }
        
        // not before minimum interval
        if let last = lastPingDate {
            let elapsed = Int(-last.timeIntervalSinceNow * 1000.0)
            guard (elapsed >= accessedConfiguration.minPingInterval) else {
                log.debug("Not pinging servers before \(accessedConfiguration.minPingInterval) milliseconds (elapsed: \(elapsed))")
                return
            }
        }
        lastPingDate = Date()

        // pings must be issued when VPN is NOT active to avoid biased response times
        guard (accessedDatabase.transient.vpnStatus == .disconnected) else {
            log.debug("Not pinging servers while on VPN, will try on next update")
            return
        }
        log.debug("Start pinging servers")

        ServersPinger.shared.ping(withDestinations: servers)
    }

    // MARK: Notifications
    
    @objc private func applicationDidBecomeActive(notification: Notification) {
        if hasEnabledUpdates {
            let currentServers = accessedProviders.serverProvider.currentServers
            pingIfOffline(servers: currentServers)
        }
    }
    
    @objc private func vpnStatusDidChange(notification: Notification) {
        if hasEnabledUpdates {
            checkOutdatedServers()
            pingIfOffline(servers: accessedProviders.serverProvider.currentServers)
        }
    }
    
    @objc private func handleReachable() {
        if hasEnabledUpdates {
            checkOutdatedServers()
            pingIfOffline(servers: accessedProviders.serverProvider.currentServers)
        }
    }
}
