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

    /// Implementation of `VPNProfile` providing WireGuard connectivity.
    public final class PIAWGTunnelProfile: NetworkExtensionProfile {

        public func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration? {

            let S = PIAWireguardConfiguration.Keys.self
            let defaultMTU = 1280

            if let dnsServers = map[S.dnsServers] as? [String], let packetSize = map[S.packetSize] as? Int {
                return PIAWireguardConfiguration(customDNSServers: dnsServers, packetSize: packetSize)
            }

            return PIAWireguardConfiguration(customDNSServers: [], packetSize: defaultMTU)

        }

        public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> String {
            let vpn = try await find()

            guard
                let session = vpn.connection as? NETunnelProviderSession,
                let data = try await session.sendProviderMessage(WGPacketTunnelProvider.Message.requestLog.data),
                !data.isEmpty
            else {
                return ""
            }

            return String(data: data, encoding: .utf8) ?? ""
        }

        public func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> Usage {
            let vpn = try await find()

            guard
                let session = vpn.connection as? NETunnelProviderSession,
                let data = try await session.sendProviderMessage(WGPacketTunnelProvider.Message.dataCount.data),
                !data.isEmpty
            else {
                throw ClientError.vpnProfileUnavailable
            }

            return Usage(uploaded: data.getInt64(start: 8), downloaded: data.getInt64(start: 0))
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
            Task { try? await find() }
        }

        /// :nodoc:
        public func save(withConfiguration configuration: VPNConfiguration, force: Bool) async throws {
            let vpn = try await find()
            try await doSave(vpn, withConfiguration: configuration, force: force)
        }

        /// :nodoc:
        public func connect(withConfiguration configuration: VPNConfiguration) async throws {
            let vpn = try await find()
            try await doSave(vpn, withConfiguration: configuration, force: true)
            let session = vpn.connection as? NETunnelProviderSession
            try session?.startTunnel(options: nil)
        }

        /// :nodoc:
        public func disconnect() async throws {
            let vpn = try await find()

            // prevent reconnection
            vpn.isOnDemandEnabled = false

            defer { vpn.connection.stopVPNTunnel() }
            try await vpn.saveToPreferences()
        }

        /// :nodoc:
        public func updatePreferences() async throws {
            let vpn = try await find()
            try await vpn.saveToPreferences()
        }

        /// :nodoc:
        public func disable() async throws {
            let vpn = try await find()
            vpn.isEnabled = false
            vpn.isOnDemandEnabled = false
            try await vpn.saveToPreferences()
        }

        /// :nodoc:
        public func remove() async throws {
            let vpn = try await find()
            try await vpn.removeFromPreferences()
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

        @discardableResult
        private func find() async throws -> NETunnelProviderManager {
            let vpn = try await PIAWGTunnelProfile.findWithBundleIdentifier(bundleIdentifier)
            self.native = vpn
            return vpn
        }

        private static func findWithBundleIdentifier(_ identifier: String?) async throws -> NETunnelProviderManager {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            var foundVPN: NETunnelProviderManager?
            for m in managers {
                guard let tunnelProtocol = m.protocolConfiguration as? NETunnelProviderProtocol else {
                    continue
                }
                guard (identifier == nil) || (tunnelProtocol.providerBundleIdentifier == identifier) else {
                    continue
                }
                foundVPN = m
                break
            }
            return foundVPN ?? NETunnelProviderManager()
        }

    }

#endif
