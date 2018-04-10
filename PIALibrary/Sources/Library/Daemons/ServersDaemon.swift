//
//  ServersDaemon.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import SwiftyBeaver

private let log = SwiftyBeaver.self

class ServersDaemon: Daemon, ConfigurationAccess, DatabaseAccess, ProvidersAccess {
    static let shared = ServersDaemon()
    
    private(set) var hasEnabledUpdates: Bool
    
    private var lastUpdateDate: Date?
    
    private var pendingUpdateTimer: DispatchSourceTimer?

    private init() {
        hasEnabledUpdates = false
    }
    
    func start() {
        let nc = NotificationCenter.default
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

    @objc private func checkOutdatedServers() {
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
        
        accessedProviders.serverProvider.download { (servers, error) in
            self.lastUpdateDate = Date()
            log.debug("Servers updated on \(self.lastUpdateDate!), will repeat in \(pollInterval) milliseconds")
            self.scheduleServersUpdate(withDelay: pollInterval)

            guard let servers = servers else {
                return
            }

            if self.accessedConfiguration.enablesServerPings {

                // pings must be issued when VPN is NOT active to avoid biased response times
                guard (self.accessedDatabase.transient.vpnStatus == .disconnected) else {
                    log.debug("Not pinging servers while on VPN, will try on next update")
                    return
                }
                log.debug("Start pinging servers")
                ServersPinger.shared.ping(withDestinations: servers)
            }
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

    // MARK: Notifications
    
    @objc private func vpnStatusDidChange(notification: Notification) {
        if hasEnabledUpdates {
            checkOutdatedServers()
        }
    }
    
    @objc private func handleReachable() {
        if hasEnabledUpdates {
            checkOutdatedServers()
        }
    }
}
