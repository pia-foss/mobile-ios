//
//  PIAWGTunnelProfile.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 06/02/2020.
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

#if os(iOS)
    import PIAWireguard
    import NetworkExtension

    private let log = PIALogger.logger(for: PIAWGTunnelProfile.self)

    /// Implementation of `VPNProfile` providing WireGuard connectivity.
    public final class PIAWGTunnelProfile: NetworkExtensionProfile {

        private var waitObserver: NSObjectProtocol?

        public func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration? {

            let S = PIAWireguardConfiguration.Keys.self
            let defaultMTU = 1280

            if let dnsServers = map[S.dnsServers] as? [String], let packetSize = map[S.packetSize] as? Int {
                return PIAWireguardConfiguration(customDNSServers: dnsServers, packetSize: packetSize)
            }

            return PIAWireguardConfiguration(customDNSServers: [], packetSize: defaultMTU)

        }

        public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: LibraryCallback<String>?) {
            find { (vpn, error) in
                guard let vpn = vpn else {
                    callback?(nil, error)
                    return
                }

                do {
                    let session = vpn.connection as? NETunnelProviderSession
                    try session?.sendProviderMessage(WGPacketTunnelProvider.Message.requestLog.data) { (data) in
                        guard let data = data, !data.isEmpty else {
                            callback?(nil, nil)
                            return
                        }
                        let log = String(data: data, encoding: .utf8)
                        callback?(log, nil)
                    }
                } catch let e {
                    callback?(nil, e)
                }
            }

        }

        public func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: LibraryCallback<Usage>?) {
            find { (vpn, error) in
                guard let vpn = vpn else {
                    callback?(nil, error)
                    return
                }

                do {
                    let session = vpn.connection as? NETunnelProviderSession
                    try session?.sendProviderMessage(WGPacketTunnelProvider.Message.dataCount.data) { (data) in
                        guard let data = data, !data.isEmpty else {
                            callback?(nil, ClientError.vpnProfileUnavailable)
                            return
                        }

                        let downloaded = data.getInt64(start: 0)
                        let uploaded = data.getInt64(start: 8)
                        let usage = Usage(uploaded: uploaded, downloaded: downloaded)
                        callback?(
                            usage,
                            nil)
                    }
                } catch let e {
                    callback?(nil, e)
                }
            }

        }

        private let bundleIdentifier: String

        /**
         Default initializer.

         - Parameter bundleIdentifier: The bundle identifier of a Packet Tunnel Provider extension subclassing `PIATunnelProvider` from `PIATunnel`.
         */
        public init(bundleIdentifier: String) {
            self.bundleIdentifier = bundleIdentifier
        }

        // MARK: VPNProfile

        /// :nodoc:
        public static var vpnType: String {
            return "PIAWG"
        }

        /// :nodoc:
        public static var isTunnel: Bool {
            return true
        }

        /// :nodoc:
        public var native: Any?

        /// :nodoc:
        public func prepare() {
            find(completionHandler: nil)
        }

        /// :nodoc:
        public func save(withConfiguration configuration: VPNConfiguration, force: Bool, _ callback: SuccessLibraryCallback?) {
            find { (vpn, error) in
                guard let vpn = vpn else {
                    callback?(error)
                    return
                }
                self.doSave(vpn, withConfiguration: configuration, force: force, callback)
            }
        }

        /// :nodoc:
        public func connect(withConfiguration configuration: VPNConfiguration, _ callback: SuccessLibraryCallback?) {
            find { (vpn, error) in
                guard let vpn = vpn else {
                    callback?(error)
                    return
                }

                self.doSave(vpn, withConfiguration: configuration, force: true) { (error) in
                    if let _ = error {
                        callback?(error)
                        return
                    }

                    let currentStatus = vpn.connection.status
                    log.debug("[WG] connect — current status: \(currentStatus.descriptionForLog)")

                    // If the tunnel is already active, stop it before starting the new one.
                    // Calling startTunnel() on a live session may silently retain the existing
                    // connection rather than switching to the new server, leaving the app in a
                    // state where it believes it is connected when it is not.
                    if currentStatus == .connected || currentStatus == .connecting || currentStatus == .reasserting {
                        log.debug("[WG] connect — stopping active tunnel before restart")
                        vpn.connection.stopVPNTunnel()
                    }

                    if currentStatus == .disconnecting {
                        log.debug("[WG] connect — waiting for .disconnected before start")
                        self.waitForDisconnectedThenStart(vpn: vpn, callback: callback)
                    } else {
                        do {
                            let session = vpn.connection as? NETunnelProviderSession
                            try session?.startTunnel(options: nil)
                            log.debug("[WG] connect — startTunnel issued")
                            callback?(nil)
                        } catch let e {
                            log.error("[WG] connect — startTunnel threw: \(e)")
                            callback?(e)
                        }
                    }
                }
            }
        }

        private func waitForDisconnectedThenStart(vpn: NETunnelProviderManager, callback: SuccessLibraryCallback?) {
            if let existing = waitObserver {
                NotificationCenter.default.removeObserver(existing)
                waitObserver = nil
            }

            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: vpn.connection, queue: .main) { [weak self, vpn] _ in
                guard vpn.connection.status == .disconnected else {
                    return
                }

                defer {
                    token.map { NotificationCenter.default.removeObserver($0) }
                    self?.waitObserver = nil
                }

                log.debug("[WG] waitForDisconnectedThenStart — disconnected, starting")
                do {
                    let session = vpn.connection as? NETunnelProviderSession
                    try session?.startTunnel(options: nil)
                    log.debug("[WG] waitForDisconnectedThenStart — startTunnel issued")
                    callback?(nil)
                } catch let e {
                    log.error("[WG] waitForDisconnectedThenStart — startTunnel threw: \(e)")
                    callback?(e)
                }
            }
            waitObserver = token
        }

        /// :nodoc:
        public func disconnect(_ callback: SuccessLibraryCallback?) {
            // A disconnect supersedes any pending connect-after-disconnect wait:
            // without this, a connect() left waiting for .disconnected would
            // restart the tunnel right after the user stops it.
            if let existing = waitObserver {
                NotificationCenter.default.removeObserver(existing)
                waitObserver = nil
            }

            find { (vpn, error) in
                guard let vpn = vpn else {
                    // Preferences could not be loaded — still stop the last known
                    // session so a disconnect always kills the tunnel.
                    (self.native as? NETunnelProviderManager)?.connection.stopVPNTunnel()
                    callback?(error)
                    return
                }

                // Stop the tunnel before the preferences round-trip below: saving
                // can hang or fail while the network is flapping, and the tunnel
                // must die regardless.
                vpn.connection.stopVPNTunnel()

                // If the tunnel was already dead, no NEVPNStatusDidChange follows
                // the stop above; sync the app status so the UI does not stay
                // stuck on a stale "connecting" state. Only do this when this
                // profile is the active one — disconnecting an inactive profile
                // (e.g. cleanup of a stale manager on launch) must never clobber
                // the status of a different, still-connected active tunnel.
                if (vpn.connection.status == .disconnected || vpn.connection.status == .invalid),
                    Client.database.transient.activeVPNProfile?.vpnType == self.vpnType
                {
                    DispatchQueue.main.async {
                        Client.database.plain.lastKnownVpnStatus = .disconnected
                        Client.database.transient.vpnStatus = .disconnected
                    }
                }

                // prevent reconnection
                vpn.isOnDemandEnabled = false

                vpn.saveToPreferences { (error) in
                    // On-demand rules may have resurrected the tunnel between the
                    // stop above and this save landing — stop again now that
                    // on-demand is disabled.
                    vpn.connection.stopVPNTunnel()
                    callback?(error)
                }
            }
        }

        /// :nodoc:
        public func updatePreferences(_ callback: SuccessLibraryCallback?) {
            // All preference mutations (server address, on-demand rules, etc.) are
            // applied by connect() via save(force: true) → doSave(). A standalone
            // loadFromPreferences → saveToPreferences round-trip with no mutations
            // races with any concurrent connect() call and causes
            // "configuration is stale" errors.
            log.debug("[WG] updatePreferences() — skipped (no-op, changes applied by connect)")
            callback?(nil)
        }

        /// :nodoc:
        public func disable(_ callback: SuccessLibraryCallback?) {
            find { (vpn, error) in
                guard let vpn = vpn else {
                    return
                }
                vpn.isEnabled = false
                vpn.isOnDemandEnabled = false
                vpn.saveToPreferences(completionHandler: callback)
            }
        }

        /// :nodoc:
        public func remove(_ callback: SuccessLibraryCallback?) {
            find { (vpn, error) in
                guard let vpn = vpn else {
                    callback?(nil)
                    return
                }
                vpn.removeFromPreferences(completionHandler: callback)
            }
        }

        // MARK: NetworkExtensionProfile

        /// :nodoc:
        public func generatedProtocol(withConfiguration configuration: VPNConfiguration) throws -> NEVPNProtocol {
            var serverAddress = configuration.server.hostname
            var serverCN = ""
            if let ip = configuration.server.bestAddress()?.ip,
                let cn = configuration.server.bestAddress()?.cn
            {
                serverAddress = ip
                serverCN = cn
            }

            let cfg = NETunnelProviderProtocol()
            cfg.providerBundleIdentifier = bundleIdentifier
            cfg.serverAddress = serverAddress
            cfg.username = Client.providers.accountProvider.publicUsername
            cfg.disconnectOnSleep = configuration.disconnectsOnSleep

            let token = configuration.server.dipUsername != nil ? configuration.server.dipUsername : (Client.providers.accountProvider.vpnToken ?? Client.providers.accountProvider.oldToken)
            guard let token = token else {
                throw ClientError.missingWireguardToken
            }

            cfg.providerConfiguration = [
                PIAWireguardConfiguration.Keys.token: token,
                PIAWireguardConfiguration.Keys.ping: configuration.server
                    .bestAddress()?.description as Any,
                PIAWireguardConfiguration.Keys.serial: configuration.server.serial,
                PIAWireguardConfiguration.Keys.cn: serverCN,
                PIAWireguardConfiguration.Keys.useIP: true
            ]

            let customCfg = configuration.customConfiguration
            if let piaCfg = customCfg as? PIAWireguardConfiguration {
                cfg.providerConfiguration?[PIAWireguardConfiguration.Keys.dnsServers] = piaCfg.customDNSServers
                cfg.providerConfiguration?[PIAWireguardConfiguration.Keys.packetSize] = piaCfg.packetSize
            }

            // Persisting CN so app knows which server it was connected to
            Client.database.plain.lastServerCN = serverCN

            return cfg
        }

        // MARK: Helpers

        private func find(completionHandler: LibraryCallback<NETunnelProviderManager>?) {
            PIAWGTunnelProfile.find(withBundleIdentifier: bundleIdentifier) { (vpn, error) in
                self.native = vpn
                completionHandler?(vpn, error)
            }
        }

        private static func find(withBundleIdentifier identifier: String?, completionHandler: LibraryCallback<NETunnelProviderManager>?) {
            NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
                guard let managers = managers else {
                    completionHandler?(nil, error)
                    return
                }
                var foundVPN: NETunnelProviderManager?
                for m in managers {
                    guard let tunnelProtocol = m.protocolConfiguration as? NETunnelProviderProtocol else {
                        continue
                    }
                    guard ((identifier == nil) || (tunnelProtocol.providerBundleIdentifier == identifier)) else {
                        continue
                    }
                    foundVPN = m
                    break
                }
                let vpn = foundVPN ?? NETunnelProviderManager()
                completionHandler?(vpn, nil)
            }
        }

    }
#endif
