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

    public func prepare(_ callback: SuccessLibraryCallback?) {
        find { _, error in
            callback?(error)
        }
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

        do {
            try writeSharedState(withConfiguration: configuration)
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

            let currentStatus = vpn.connection.status
            log.debug("[PlatformSDK] connect — current status: \(currentStatus.descriptionForLog)")

            // If the tunnel is already active, ask the running extension to switch to the new
            // server in place (see PIAPacketTunnelProvider.handleAppMessage) instead of stopping
            // and relaunching the Network Extension process. Only the shared-state write
            // (`writeSharedState`) is needed for this — the extension resolves its endpoints from
            // PIATunnelSharedState, not from `protocolConfiguration` — so we deliberately skip
            // `doSave`'s `vpn.saveToPreferences`/`loadFromPreferences`.
            switch currentStatus {
            case .connected, .connecting, .reasserting:
                do {
                    try self.writeSharedState(withConfiguration: configuration)
                } catch {
                    callback?(error)
                    return
                }
                log.debug("[PlatformSDK] connect — switching location on the active tunnel")
                self.sendSwitchLocationMessage(to: vpn, callback: callback)
                return
            default:
                break
            }

            self.doSave(vpn, withConfiguration: configuration, force: true) { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }

                switch currentStatus {
                case .disconnecting:
                    log.debug("[PlatformSDK] connect — waiting for .disconnected before start")
                    self.waitForDisconnectedThenStart(vpn: vpn, callback: callback)

                default:
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

    /// Writes the tunnel's connection target and credentials to `PIATunnelSharedState` — the only
    /// input a live `switchLocation` needs, since the extension resolves its endpoints from here,
    /// not from `protocolConfiguration`. Carries the existing server-list cache forward so this
    /// wholesale write doesn't wipe it; the extension re-fetches on its own when it's empty or stale.
    private func writeSharedState(withConfiguration configuration: VPNConfiguration) throws {
        let server = connectableServer(for: configuration.server)
        let tunnelProtocol = desiredTunnelProtocol()
        let openVPN = try openVPNSettings(for: server)
        let wireGuard = wireGuardSettings(for: server)

        // Automatic selection: `configuration.server` is already resolved to the best server, so a
        // nil `preferredServer` — not `server.isAutomatic` — is the reliable signal. A nil
        // `selectedLocationId` makes the extension fan out across all servers, fastest first
        // (`PIAEndpointRepository.generateConfigurations`). A DIP target is never automatic.
        let isAutomaticSelection = server.dipToken == nil && Client.preferences.preferredServer == nil

        let existing = PIATunnelSharedState.read()

        PIATunnelSharedState.write(
            .init(
                selectedLocationId: isAutomaticSelection ? nil : server.identifier,
                selectedDipServer: server.dipToken != nil ? server : nil,
                selectedProtocol: tunnelProtocol,
                openVPN: openVPN,
                wireGuard: wireGuard,
                servers: existing.servers,
                serversFetchedAt: existing.serversFetchedAt,
                latencyByServerId: existing.latencyByServerId
            )
        )
    }

    private func sendSwitchLocationMessage(to vpn: NETunnelProviderManager, callback: SuccessLibraryCallback?) {
        guard let session = vpn.connection as? NETunnelProviderSession else {
            callback?(nil)
            return
        }
        do {
            let data = try JSONEncoder().encode(PIAPacketTunnelRequest.switchLocation)
            try session.sendProviderMessage(data, responseHandler: nil)
            log.debug("[PlatformSDK] connect — switchLocation message sent")
            callback?(nil)
        } catch {
            log.error("[PlatformSDK] connect — switchLocation send failed: \(error)")
            callback?(error)
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
        if let observer = waitObserver {
            NotificationCenter.default.removeObserver(observer)
            waitObserver = nil
        }
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
                callback?(error)
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

    /// Resolves the concrete server the tunnel should connect to.
    ///
    /// The "Automatic" region — and the first-launch state where the user has never picked a region
    /// then taps Connect — is represented by a sentinel server (`Server.automatic`, identifier
    /// `"auto"`) that is not part of the real server list, so the extension can't match it and would
    /// resolve no endpoints. In that case connect to the fastest server we know of (the lowest
    /// measured ping, via `bestServer`), falling back to the first available server. A Dedicated IP
    /// target is always concrete, so it passes through untouched.
    private func connectableServer(for server: Server) -> Server {
        if server.dipToken != nil {
            return server
        }

        let servers = Client.providers.serverProvider.currentServers
        let isConcrete = servers.contains { $0.identifier == server.identifier && $0.dipToken == nil }
        if isConcrete {
            return server
        }

        // Automatic / unresolved selection: prefer the fastest server, then any non-offline one.
        return Client.providers.serverProvider.bestServer ?? servers.first { !$0.offline } ?? server
    }

    /// Maps the user's selected VPN protocol to the protocol the PlatformSDK tunnel should run.
    /// OpenVPN maps to `.openVPN`, WireGuard to `.wireGuard`, automatic to `.automatic`. Legacy
    /// IKEv2 — which the PlatformSDK tunnel cannot run — and any unrecognised value fall back to
    /// `.automatic`, the default (the app also migrates such users off IKEv2; this is the defensive
    /// fallback). The work runs in the PlatformSDK extension (Kape SDK), which supports OpenVPN and
    /// WireGuard on both iOS and tvOS — so this mapping is platform-agnostic and does not gate on
    /// `os(iOS)`.
    private func desiredTunnelProtocol() -> PIATunnelSharedState.TunnelProtocol {
        switch KapePlatformSDKVPNType(rawValue: Client.preferences.vpnType) {
        case .openVPN:
            return .openVPN
        case .wireGuard:
            return .wireGuard
        case .automatic:
            return .automatic
        case .iKEv2, nil:
            return .automatic
        }
    }

    /// The user's custom DNS resolvers for the given VPN type (the Settings → Network choice),
    /// empty when they kept the PIA default (server-pushed DNS). iOS-only feature; tvOS has no UI.
    ///
    /// Read from the raw persisted custom-configuration map rather than the parsed
    /// `VPNCustomConfiguration` so this does not depend on the legacy `PIAWireguard` /
    /// `TunnelKitOpenVPN` types (which are being removed). The stored maps are plain
    /// `[String: Any]`: WireGuard keeps a flat `customDNSServers`, while OpenVPN nests it under
    /// `configuration.dnsServers` (the auto-synthesised `OpenVPN.ProviderConfiguration` Codable shape).
    func customDnsServers(forVPNType vpnType: KapePlatformSDKVPNType) -> [String] {
        guard let map = Client.database.plain.vpnCustomConfigurationMaps?[vpnType.rawValue] else {
            return []
        }

        if let wireGuardDns = map["customDNSServers"] as? [String] {
            return wireGuardDns
        }

        if let session = map["configuration"] as? [String: Any], let openVPNDns = session["dnsServers"] as? [String] {
            return openVPNDns
        }

        return []
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

            let platformSDKManagers = managers.filter { manager in
                (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier == identifier
            }

            // Prefer an already-running manager so we adopt the live tunnel; otherwise take the first.
            let foundVPN =
                platformSDKManagers.first { manager in
                    switch manager.connection.status {
                    case .connected, .connecting, .reasserting, .disconnecting:
                        return true
                    default:
                        return false
                    }
                } ?? platformSDKManagers.first

            let vpn = foundVPN ?? NETunnelProviderManager()
            completionHandler?(vpn, nil)
        }
    }
}
