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

    /// App-group UserDefaults, the source of all user-set connection config read by this profile.
    /// Internal (not private) so the per-protocol extensions in `+WireGuard`/`+OpenVPN` can read it.
    lazy var sharedDefaults = UserDefaults(suiteName: AppConstants.appGroup) ?? .standard

    public static let vpnType: String = "PlatformSDK"

    public static var isTunnel: Bool {
        return true
    }

    public var native: Any?

    public init(bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier
    }

    public func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol {
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = self.bundleIdentifier
        // The PlatformSDK extension reads all connection parameters from PIATunnelSharedState,
        // not from providerConfiguration. serverAddress is set to empty; endpoints are
        // resolved in PIAEndpointRepository from the shared state written in doSave.
        proto.serverAddress = ""
        return proto
    }

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
        let protocolConfiguration = generatedProtocol(withConfiguration: configuration)
        vpn.protocolConfiguration = protocolConfiguration

        // TODO: [PlatformSDK] Temporary — use configuration.name
        vpn.localizedDescription = "[PlatformSDK] \(configuration.name)"
        vpn.isOnDemandEnabled = Client.providers.vpnProvider.isVPNConnected || vpn.isEnabled ? configuration.isOnDemand : false  //if the VPN is disconnected, don't activate the onDemand property to don't autoconnect the VPN without user permission

        // The PlatformSDK extension resolves its endpoints from this shared state.
        // Snapshot the resolved target server and the current server list together so the extension
        // connects to exactly what the app chose — including Automatic, where preferredServer is nil
        // but targetServer resolves to a concrete server.
        do {
            let tunnelProtocol = desiredTunnelProtocol()
            let openVPN = try openVPNSettings()
            let wireGuard = wireGuardSettings()

            PIATunnelSharedState.write(
                .init(
                    selectedLocationId: configuration.server.identifier,
                    servers: Client.database.plain.cachedServers,
                    selectedProtocol: tunnelProtocol,
                    openVPNCaCertificate: openVPN.caCertificate,
                    openVPNUsername: openVPN.username,
                    openVPNPassword: openVPN.password,
                    openVPNOvpnConfig: openVPN.ovpnConfig,
                    openVPNPort: openVPN.port,
                    openVPNTransport: openVPN.transport,
                    openVPNMtu: openVPN.mtu,
                    wireGuardMtu: wireGuard.mtu
                ),
                appGroup: AppConstants.appGroup
            )
        } catch {
            callback?(error)
            return
        }

        // VPN Kill Switch (Settings → Privacy Features) integration.
        // The toggle is `Client.preferences.isPersistentConnection`, surfaced here as
        // `configuration.isOnDemand`. PIA implements the kill switch via on-demand — exactly like
        // the IKEv2 / OpenVPN / WireGuard profiles do (NetworkExtensionProfile.doSave): when it is
        // on, `applyOnDemandRules` installs a catch-all `NEOnDemandRuleConnect`, so iOS keeps the
        // VPN required, re-establishes it if it drops, and holds back un-tunneled traffic until the
        // tunnel is up. `isOnDemandEnabled` (set above) gates this.
        applyOnDemandRules(to: vpn, force: force, configuration: configuration)

        #if os(iOS)
            // Keep `includeAllNetworks` OFF — it is NOT how PIA implements the kill switch (see the
            // on-demand wiring above). Setting it ON (the OS-level "no exceptions" kill switch)
            // prevents iOS from doing a seamless interface handover: on a wifi↔cellular switch the
            // tunnel is forced to tear down and re-establish on the new interface, and because every
            // non-tunnel packet is blocked during that window connectivity is lost and often never
            // recovers. The SDK's `.standard` kill switch maps to `includeAllNetworks = false` for
            // the same reason, and PIA's existing OpenVPN/WireGuard profiles force it off for these
            // protocols too. Roaming recovery is handled inside the extension by KapePathReconnector.
            // Local-network access stays available.
            vpn.protocolConfiguration?.includeAllNetworks = false
            vpn.protocolConfiguration?.excludeLocalNetworks = true
        #endif

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

    // MARK: - Helpers

    /// Maps the user's selected VPN protocol to the protocol the PlatformSDK tunnel should run.
    /// "PIA" (OpenVPN) maps to `.openVPN` on iOS; all other types (including "PIAWG") map to `.wireGuard`.
    private func desiredTunnelProtocol() -> PIATunnelSharedState.TunnelProtocol {
        switch Client.preferences.vpnType {
        case "PIA":
            #if os(iOS) && canImport(TunnelKitOpenVPN)
                return .openVPN
            #else
                return .wireGuard
            #endif
        case "PIAWG":
            return .wireGuard
        default:
            return .wireGuard
        }
    }

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
