//
//  IKEv2Profile.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 21/01/2019.
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
import NetworkExtension

private let log = PIALogger.logger(for: IKEv2Profile.self)

/// Implementation of `VPNProfile` providing IKEv2 connectivity.
public final class IKEv2Profile: NetworkExtensionProfile {

    private var currentVPN: NEVPNManager {
        return NEVPNManager.shared()
    }

    public init() {
    }

    // MARK: VPNProfile

    /// :nodoc:
    public static var vpnType: String {
        return "IKEv2"
    }

    /// :nodoc:
    public static var isTunnel: Bool {
        return false
    }

    /// :nodoc:
    public var native: Any? {
        return currentVPN
    }

    /// :nodoc:
    public func prepare() {
        currentVPN.loadFromPreferences { (_) in
        }
    }

    /// :nodoc:
    public func save(withConfiguration configuration: VPNConfiguration, force: Bool) async throws {
        try await currentVPN.loadFromPreferences()
        try await doSave(currentVPN, withConfiguration: configuration, force: force)
    }

    /// :nodoc:
    public func connect(withConfiguration configuration: VPNConfiguration) async throws {
        try await save(withConfiguration: configuration, force: true)

        // If the tunnel is already active, stop it before starting the new one.
        // Calling startVPNTunnel() on a connected IKEv2 tunnel may silently retain
        // the existing connection rather than switching to the new server, resulting
        // in the app believing it is connected when it is not.
        let currentStatus = currentVPN.connection.status
        if currentStatus == .connected || currentStatus == .connecting || currentStatus == .reasserting {
            currentVPN.connection.stopVPNTunnel()
        }
        try currentVPN.connection.startVPNTunnel()
    }

    /// :nodoc:
    public func disconnect() async throws {
        try await currentVPN.loadFromPreferences()

        // prevent reconnection
        currentVPN.isOnDemandEnabled = false

        defer { currentVPN.connection.stopVPNTunnel() }
        try await currentVPN.saveToPreferences()
    }

    /// :nodoc:
    public func updatePreferences() async throws {
        // For IKEv2 there is nothing to update here: all preference changes
        // (server address, on-demand rules, etc.) are applied by connect() via
        // save(force:true) → doSave(). A standalone loadFromPreferences →
        // saveToPreferences round-trip with no mutations races with any
        // concurrent connect() call and causes "configuration is stale" errors.
        log.debug("[IKEv2] updatePreferences() — skipped (no-op for IKEv2, changes applied by connect)")
    }

    /// :nodoc:
    public func remove() async throws {
        try await currentVPN.loadFromPreferences()
        try await currentVPN.removeFromPreferences()
    }

    /// :nodoc:
    public func disable() async throws {
        try await currentVPN.loadFromPreferences()
        currentVPN.isEnabled = false
        currentVPN.isOnDemandEnabled = false
        try await currentVPN.saveToPreferences()
    }

    /// :nodoc:
    public func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration? {
        return nil
    }

    /// :nodoc:
    public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> String {
        currentVPN.description
    }

    /// :nodoc:
    public func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?) async throws -> Usage {
        throw ClientError.unsupported
    }

    // MARK: NetworkExtensionProfile

    /// :nodoc:
    public func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol {

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

        let cfg = NEVPNProtocolIKEv2()
        if let bestAddress = configuration.server.bestAddress() {
            cfg.serverAddress = bestAddress.ip

            // Persisting CN so app knows which server it was connected to
            Client.database.plain.lastServerCN = bestAddress.cn
        } else {
            cfg.serverAddress = configuration.server.hostname
        }
        cfg.remoteIdentifier = configuration.server.hostname
        cfg.localIdentifier = configuration.server.dipUsername ?? username
        cfg.username = configuration.server.dipUsername ?? username
        cfg.passwordReference = configuration.server.dipToken != nil ? configuration.server.dipPassword() : passwordReference

        cfg.authenticationMethod = .none
        cfg.disconnectOnSleep = false
        cfg.useExtendedAuthentication = true

        if let encryption = IKEv2EncryptionAlgorithm(rawValue: Client.preferences.ikeV2EncryptionAlgorithm) {
            cfg.ikeSecurityAssociationParameters.encryptionAlgorithm = encryption.networkExtensionValue()
            cfg.childSecurityAssociationParameters.encryptionAlgorithm = encryption.networkExtensionValue()
        } else {
            cfg.ikeSecurityAssociationParameters.encryptionAlgorithm = IKEv2EncryptionAlgorithm.defaultAlgorithm.networkExtensionValue()
            cfg.childSecurityAssociationParameters.encryptionAlgorithm = IKEv2EncryptionAlgorithm.defaultAlgorithm.networkExtensionValue()
        }

        if let integrity = IKEv2IntegrityAlgorithm(rawValue: Client.preferences.ikeV2IntegrityAlgorithm) {
            cfg.ikeSecurityAssociationParameters.integrityAlgorithm = integrity.networkExtensionValue()
            cfg.childSecurityAssociationParameters.integrityAlgorithm = integrity.networkExtensionValue()
        }

        if Client.preferences.ikeV2PacketSize != 0 {
            cfg.mtu = Client.preferences.ikeV2PacketSize
        }

        log.debug("IKEv2 Configuration")
        log.debug("-------------------")
        log.debug("\(cfg)")
        log.debug("-------------------")

        return cfg
    }
}
