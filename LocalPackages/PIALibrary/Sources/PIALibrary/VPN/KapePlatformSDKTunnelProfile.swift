//
//  KapePlatformSDKTunnelProfile.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 09.06.26.
//  Copyright © 2026 Private Internet Access, Inc.
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

import NetworkExtension

private let log = PIALogger.logger(for: KapePlatformSDKTunnelProfile.self)

public final class KapePlatformSDKTunnelProfile: NetworkExtensionProfile {
    private let bundleIdentifier: String
    private var waitObserver: NSObjectProtocol?

    public init(bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier
    }

    public func generatedProtocol(withConfiguration configuration: VPNConfiguration) throws -> NEVPNProtocol {
        let proto = NETunnelProviderProtocol()
        proto.serverAddress = ""  //self.serverAddress
        proto.providerBundleIdentifier = self.bundleIdentifier
        return proto
    }

    public static let vpnType: String = "PlatformSDK"

    public static var isTunnel: Bool {
        return true
    }

    public var native: Any?

    public func prepare() {
        find(completionHandler: nil)
    }

    public func save(withConfiguration configuration: VPNConfiguration, force: Bool, _ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(error)
                return
            }
            self.doSave(vpn, withConfiguration: configuration, force: force, callback)
        }
    }

    public func doSave(_ vpn: NEVPNManager, withConfiguration configuration: VPNConfiguration, force: Bool, _ callback: SuccessLibraryCallback?) {
        do {
            vpn.protocolConfiguration = try generatedProtocol(withConfiguration: configuration)
        } catch {
            callback?(error)
            return
        }

        let protocolConfiguration = vpn.protocolConfiguration!  // Safe to force unwrap

        // TODO: [PlatformSDK] Temporary — use configuration.name
        vpn.localizedDescription = "[PlatformSDK] \(configuration.name)"
        vpn.isOnDemandEnabled = Client.providers.vpnProvider.isVPNConnected || vpn.isEnabled ? configuration.isOnDemand : false  //if the VPN is disconnected, don't activate the onDemand property to don't autoconnect the VPN without user permission

        // Reuse the shared NMT-based on-demand rule construction (same logic the IKEv2 /
        // OpenVPN / WireGuard profiles use via NetworkExtensionProfile.doSave).
        applyOnDemandRules(to: vpn, force: force, configuration: configuration)

        #if os(iOS)
            // The PlatformSDK tunnel relies on the OS-level `includeAllNetworks` flag to enforce
            // the kill switch — the SDK does not block traffic itself. Drive it from the user's
            // Kill Switch setting (isPersistentConnection, surfaced here as configuration.isOnDemand).
            // Local-network access is kept available so system/local services keep working while
            // the tunnel is up.
            vpn.protocolConfiguration?.includeAllNetworks = configuration.isOnDemand
            vpn.protocolConfiguration?.excludeLocalNetworks = true
        #endif

        //        log.debug("Configured with server: \(protocolConfiguration.serverAddress!)")
        //        log.debug("Username: \(protocolConfiguration.username!)")
        //        log.debug("On-demand is now \(vpn.isOnDemandEnabled ? "ENABLED" : "DISABLED")")
        //        log.debug("Raw manager: \(vpn)")

        vpn.isEnabled = true
        vpn.saveToPreferences { (error) in
            if let error = error {
                callback?(error)
                return
            }
            vpn.loadFromPreferences { (error) in
                callback?(nil)
            }
        }
    }

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
                log.debug("[PlatformSDK] connect — current status: \(currentStatus.descriptionForLog)")

                // If the tunnel is already active, stop it before starting the new one.
                // Calling startTunnel() on a live session may silently retain the existing
                // connection rather than switching to the new server, leaving the app in a
                // state where it believes it is connected when it is not.
                if currentStatus == .connected || currentStatus == .connecting || currentStatus == .reasserting {
                    log.debug("[PlatformSDK] connect — stopping active tunnel before restart")
                    vpn.connection.stopVPNTunnel()
                }

                if currentStatus == .disconnecting {
                    log.debug("[PlatformSDK] connect — waiting for .disconnected before start")
                    self.waitForDisconnectedThenStart(vpn: vpn, callback: callback)
                } else {
                    do {
                        let session = vpn.connection as? NETunnelProviderSession
                        try session?.startTunnel(options: nil)
                        log.debug("[PlatformSDK] connect — startTunnel issued")
                        callback?(nil)
                    } catch let e {
                        log.error("[PlatformSDK] connect — startTunnel threw: \(e)")
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

            log.debug("[PlatformSDK] waitForDisconnectedThenStart — disconnected, starting")
            do {
                let session = vpn.connection as? NETunnelProviderSession
                try session?.startTunnel(options: nil)
                log.debug("[PlatformSDK] waitForDisconnectedThenStart — startTunnel issued")
                callback?(nil)
            } catch let e {
                log.error("[PlatformSDK] waitForDisconnectedThenStart — startTunnel threw: \(e)")
                callback?(e)
            }
        }
        waitObserver = token
    }

    public func disconnect(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(error)
                return
            }

            // prevent reconnection
            vpn.isOnDemandEnabled = false

            vpn.saveToPreferences { (error) in
                if let error = error {
                    vpn.connection.stopVPNTunnel()
                    callback?(error)
                    return
                }
                vpn.connection.stopVPNTunnel()
                callback?(nil)
            }
        }
    }

    public func updatePreferences(_ callback: SuccessLibraryCallback?) {
        log.debug("[PlatformSDK] updatePreferences() — skipped (no-op, changes applied by connect)")
        callback?(nil)
    }

    public func remove(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(nil)
                return
            }
            vpn.removeFromPreferences(completionHandler: callback)
        }
    }

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

    public func parsedCustomConfiguration(from map: [String: Any]) -> (any VPNCustomConfiguration)? {
        nil
    }

    public func requestLog(withCustomConfiguration customConfiguration: (any VPNCustomConfiguration)?, _ callback: LibraryCallback<String>?) {
        callback?(nil, nil)
    }

    // The Platform SDK exposes no public tx/rx byte API
    public func requestDataUsage(withCustomConfiguration customConfiguration: (any VPNCustomConfiguration)?, _ callback: LibraryCallback<Usage>?) {
        callback?(nil, nil)
    }

    // MARK: Helpers

    private func find(completionHandler: LibraryCallback<NETunnelProviderManager>?) {
        KapePlatformSDKTunnelProfile.find(withBundleIdentifier: bundleIdentifier) { (vpn, error) in
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
