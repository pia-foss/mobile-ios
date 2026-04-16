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

        /// :nodoc:
        public func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration? {
            //Migrate OVPN library
            if map.count > 5 {
                //old client. needs migration
                let newMap = migrateOVPNConfigurationMap(from: map)
                return try? OpenVPNProvider.Configuration.parsed(from: newMap)
            }
            return try? OpenVPNProvider.Configuration.parsed(from: map)
        }

        private func migrateOVPNConfigurationMap(from map: [String: Any]) -> [String: Any] {
            var updatedMap = [String: Any]()
            updatedMap["appGroup"] = map["AppGroup"]
            updatedMap["prefersResolvedAddresses"] = map["PrefersResolvedAddresses"]
            updatedMap["masksPrivateData"] = map["MasksPrivateData"]
            updatedMap["shouldDebug"] = map["Debug"]

            var sessionConfigurationMap = [String: Any]()
            sessionConfigurationMap["cipher"] = map["CipherAlgorithm"]
            sessionConfigurationMap["digest"] = map["DigestAlgorithm"]
            sessionConfigurationMap["ca"] = map["CA"]
            sessionConfigurationMap["mtu"] = map["MTU"]
            sessionConfigurationMap["usesPIAPatches"] = map["UsesPIAPatches"]
            sessionConfigurationMap["dnsServers"] = map["DNSServers"]
            sessionConfigurationMap["endpointProtocols"] = map["EndpointProtocols"]
            sessionConfigurationMap["renegotiatesAfter"] = map["RenegotiatesAfter"]

            updatedMap["sessionConfiguration"] = sessionConfigurationMap

            return updatedMap
        }

        /// :nodoc:
        public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> String {
            let vpn = try await find()

            guard
                let session = vpn.connection as? NETunnelProviderSession,
                let data = try await session.sendProviderMessage(OpenVPNProvider.Message.requestLog.data),
                !data.isEmpty
            else {
                return (customConfiguration as? OpenVPNProvider.Configuration).flatMap { lastLogSnapshot(withProviderConfiguration: $0) } ?? ""
            }

            return String(data: data, encoding: .utf8) ?? ""
        }

        /// :nodoc:
        public func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> Usage {
            let vpn = try await find()

            guard
                let session = vpn.connection as? NETunnelProviderSession,
                let data = try await session.sendProviderMessage(OpenVPNProvider.Message.dataCount.data),
                !data.isEmpty
            else {
                throw ClientError.vpnProfileUnavailable
            }

            return Usage(uploaded: data.getInt64(start: 8), downloaded: data.getInt64(start: 0))
        }

        // MARK: NetworkExtensionProfile

        /// :nodoc:
        public func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol {

            var serverAddress = ""
            var customCfg = configuration.customConfiguration
            if let piaCfg = customCfg as? OpenVPNProvider.Configuration {
                var builder = piaCfg.builder()

                if let usesVanillaOpenVPN = configuration.server.bestAddressForOVPN(tcp: true)?.van, usesVanillaOpenVPN == true {
                    builder.sessionConfiguration.usesPIAPatches = false
                } else {
                    builder.sessionConfiguration.usesPIAPatches = true  //SET TO FALSE TO USE NATIVE OVPN
                }

                if let protocols = builder.sessionConfiguration.endpointProtocols, protocols.contains(where: { $0.socketType == .tcp }) {
                    if let bestAddress = configuration.server.bestAddressForOVPN(tcp: true) {
                        serverAddress = bestAddress.ip
                        builder.resolvedAddresses = [bestAddress.ip]

                        // Persisting CN so app knows which server it was connected to
                        Client.database.plain.lastServerCN = bestAddress.cn
                    }
                } else {
                    if let bestAddress = configuration.server.bestAddressForOVPN(tcp: false) {
                        serverAddress = bestAddress.ip
                        builder.resolvedAddresses = [bestAddress.ip]

                        // Persisting CN so app knows which server it was connected to
                        Client.database.plain.lastServerCN = bestAddress.cn
                    }
                }
                customCfg = builder.build()
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

        @discardableResult
        private func find() async throws -> NETunnelProviderManager {
            let vpn = try await PIATunnelProfile.findWithBundleIdentifier(bundleIdentifier)
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

        private func lastLogSnapshot(withProviderConfiguration providerConfiguration: OpenVPNProvider.Configuration) -> String? {
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
