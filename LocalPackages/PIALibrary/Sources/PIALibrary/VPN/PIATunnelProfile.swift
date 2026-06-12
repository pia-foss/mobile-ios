//
//  PIATunnelProfile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
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
#if os(iOS)
    import Foundation
    import TunnelKitOpenVPN
    import NetworkExtension

    /// Implementation of `VPNProfile` providing OpenVPN connectivity.
    public final class PIATunnelProfile: NetworkExtensionProfile {
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
            return "PIA"
        }

        /// :nodoc:
        public static var isTunnel: Bool {
            return true
        }

        /// :nodoc:
        public var native: Any?

        public var connectionDate: Date? {
            guard let native = native as? NETunnelProviderManager else { return nil }
            return native.connection.connectedDate
        }

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
                    do {
                        let session = vpn.connection as? NETunnelProviderSession
                        try session?.startTunnel(options: nil)
                        callback?(nil)
                    } catch let e {
                        callback?(e)
                    }
                }
            }
        }

        /// :nodoc:
        public func disconnect(_ callback: SuccessLibraryCallback?) {
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
            find { (vpn, error) in
                guard let vpn = vpn else {
                    callback?(error)
                    return
                }

                vpn.saveToPreferences { (error) in
                    if let error = error {
                        callback?(error)
                        return
                    }
                    callback?(nil)
                }
            }
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

        /// :nodoc:
        public func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration? {
            // Configurations written by the current client serialize an
            // `OpenVPN.ProviderConfiguration` directly (see `serialized()`), so a
            // straight decode handles the common case. `fragmentsAllowed` mirrors
            // TunnelKit's own `fromDictionary(_:_:)` helper.
            if let data = try? JSONSerialization.data(withJSONObject: map, options: .fragmentsAllowed),
                let configuration = try? JSONDecoder().decode(OpenVPN.ProviderConfiguration.self, from: data)
            {
                return configuration
            }

            // Legacy fall-through: the persisted map predates the TunnelKit fork change
            // (old `OpenVPNProvider.Configuration` layout) and can no longer be decoded
            // into the current type. Returning nil makes the caller fall back to the
            // default OpenVPN configuration, guaranteeing a working connection — at the
            // cost of resetting any custom OpenVPN tweaks to defaults.
            // TODO: verify the upgrade path from pre-fork builds on device.
            log.error("[OpenVPN] Unable to decode persisted custom configuration; falling back to defaults")
            return nil
        }

        /// :nodoc:
        public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: ((String?, Error?) -> Void)?) {
            guard let providerConfiguration = customConfiguration as? OpenVPN.ProviderConfiguration else {
                callback?(nil, nil)
                return
            }

            // The Kape TunnelKit fork no longer exposes the `requestLog` IPC message.
            // The tunnel writes its debug log to a file in the shared app group; fall
            // back to the snapshot persisted by `PIALogHandler` when it is unavailable.
            if let logURL = providerConfiguration.urlForDebugLog,
                let contents = try? String(contentsOf: logURL, encoding: .utf8),
                !contents.isEmpty
            {
                callback?(contents, nil)
                return
            }

            callback?(lastLogSnapshot(withProviderConfiguration: providerConfiguration), nil)
        }

        /// :nodoc:
        public func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: ((Usage?, Error?) -> Void)?) {
            guard let providerConfiguration = customConfiguration as? OpenVPN.ProviderConfiguration else {
                callback?(nil, nil)
                return
            }

            // The fork publishes data counters to the shared app group instead of
            // answering a `dataCount` IPC message.
            guard let dataCount = providerConfiguration.dataCount else {
                callback?(nil, ClientError.vpnProfileUnavailable)
                return
            }

            let usage = Usage(uploaded: UInt64(dataCount.sent), downloaded: UInt64(dataCount.received))
            callback?(usage, nil)
        }

        // MARK: NetworkExtensionProfile

        /// :nodoc:
        public func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol {

            var serverAddress = ""
            var customCfg = configuration.customConfiguration
            if let piaCfg = customCfg as? OpenVPN.ProviderConfiguration {
                var sessionBuilder = piaCfg.configuration.builder()

                if let usesVanillaOpenVPN = configuration.server.bestAddressForOVPN(tcp: true)?.van, usesVanillaOpenVPN == true {
                    sessionBuilder.usesPIAPatches = false
                } else {
                    sessionBuilder.usesPIAPatches = true  //SET TO FALSE TO USE NATIVE OVPN
                }

                // The fork models endpoints as `remotes` (address + protocol) rather
                // than separate `endpointProtocols` / `resolvedAddresses`. The stored
                // protocols carry a sentinel address (see `OpenVPNProvider+Compat`);
                // bind each one to the freshly resolved server IP here.
                let protocols = sessionBuilder.endpointProtocols ?? []
                let prefersTCP = protocols.contains { $0.socketType == .tcp }
                if let bestAddress = configuration.server.bestAddressForOVPN(tcp: prefersTCP) {
                    serverAddress = bestAddress.ip
                    sessionBuilder.remotes = protocols.map { TunnelKitCore.Endpoint(bestAddress.ip, $0) }

                    // Persisting CN so app knows which server it was connected to
                    Client.database.plain.lastServerCN = bestAddress.cn
                }

                var rebuilt = OpenVPN.ProviderConfiguration(
                    OpenVPNProvider.title,
                    appGroup: Client.Configuration.appGroup,
                    configuration: sessionBuilder.build()
                )
                // Carry over provider-level fields not held by `OpenVPN.Configuration`.
                rebuilt.shouldDebug = piaCfg.shouldDebug
                rebuilt.username = piaCfg.username
                rebuilt.masksPrivateData = piaCfg.masksPrivateData
                rebuilt.versionIdentifier = piaCfg.versionIdentifier
                rebuilt.debugLogPath = piaCfg.debugLogPath
                rebuilt.debugLogFormat = piaCfg.debugLogFormat
                customCfg = rebuilt
            }

            var username = configuration.username
            var passwordReference = configuration.passwordReference

            if let accountVpnUsername = Client.providers.accountProvider.vpnTokenUsername,
                let accountVpnPassword = Client.providers.accountProvider.vpnTokenPassword
            {
                username = accountVpnUsername
                Client.database.secure.setPassword(accountVpnPassword, for: username)
            }

            if let accountVpnPasswordreference = Client.database.secure.passwordReference(for: username) {
                passwordReference = accountVpnPasswordreference
            }

            let cfg = NETunnelProviderProtocol()
            cfg.disconnectOnSleep = configuration.disconnectsOnSleep
            cfg.username = configuration.server.dipUsername ?? username
            cfg.passwordReference = configuration.server.dipUsername != nil ? configuration.server.dipPassword() : passwordReference
            cfg.serverAddress = serverAddress
            cfg.providerBundleIdentifier = bundleIdentifier
            cfg.providerConfiguration = customCfg?.serialized()
            return cfg
        }

        // MARK: Helpers

        private func find(completionHandler: LibraryCallback<NETunnelProviderManager>?) {
            PIATunnelProfile.find(withBundleIdentifier: bundleIdentifier) { (vpn, error) in
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

        private func lastLogSnapshot(withProviderConfiguration providerConfiguration: OpenVPN.ProviderConfiguration) -> String? {
            guard let defaults = UserDefaults(suiteName: Client.Configuration.appGroup) else {
                return nil
            }
            guard let lines = defaults.array(forKey: Client.Configuration.debugLogKey) as? [String] else {
                return nil
            }
            return lines.joined(separator: "\n")
        }
    }
#endif
