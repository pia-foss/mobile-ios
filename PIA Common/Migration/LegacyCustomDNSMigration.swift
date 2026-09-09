//
//  LegacyCustomDNSMigration.swift
//  PIA Common
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: LegacyCustomDNSMigration.self)

/// One-time backfill of settings (DNS, cipher, auth, port, small packets) that only ever lived in
/// the legacy custom-configuration maps, into the app-group keys the PlatformSDK tunnel reads.
enum LegacyCustomDNSMigration {

    /// OpenVPN's session settings nest under `"sessionConfiguration"` (`mobile-ios-openvpn`, what
    /// every real legacy install shipped) or `"configuration"` (the vendored Kape fork, briefly used
    /// during the PlatformSDK transition). Both are checked. Same split for the remote list:
    /// `"endpointProtocols"` (`"<socketType>:<port>"`) vs `"remotes"` (`"<address>:<socketType>:<port>"`)
    /// — taking the last `:`-separated component reads the port out of either.
    private enum LegacyKey {
        static let maps = "VPNCustomConfigurationMaps"
        static let wireGuardMap = "PIAWG"
        static let openVPNMap = "PIA"
        static let wireGuardServers = "customDNSServers"
        static let openVPNSessionConfiguration = "sessionConfiguration"
        static let openVPNConfiguration = "configuration"
        static let openVPNServers = "dnsServers"
        static let openVPNCipher = "cipher"
        static let openVPNDigest = "digest"
        static let openVPNEndpointProtocols = "endpointProtocols"
        static let openVPNRemotes = "remotes"
        static let wireGuardUseSmallPackets = "WireGuardUseSmallPackets"
    }

    private static func openVPNSessionConfiguration(from maps: [String: [String: Any]]) -> [String: Any]? {
        guard let map = maps[LegacyKey.openVPNMap] else {
            return nil
        }

        return (map[LegacyKey.openVPNSessionConfiguration] ?? map[LegacyKey.openVPNConfiguration]) as? [String: Any]
    }

    /// `nil` for a protocol means "leave the preference alone": already populated, or nothing to
    /// migrate.
    static func migratedServers(
        from maps: [String: [String: Any]],
        currentOpenVPN: [String],
        currentWireGuard: [String]
    ) -> (openVPN: [String]?, wireGuard: [String]?) {
        var wireGuard: [String]?
        var openVPN: [String]?

        if currentWireGuard.isEmpty,
            let servers = maps[LegacyKey.wireGuardMap]?[LegacyKey.wireGuardServers] as? [String],
            !servers.isEmpty
        {
            wireGuard = servers
        }

        if currentOpenVPN.isEmpty,
            let configuration = openVPNSessionConfiguration(from: maps),
            let servers = configuration[LegacyKey.openVPNServers] as? [String],
            !servers.isEmpty
        {
            openVPN = servers
        }

        return (openVPN: openVPN, wireGuard: wireGuard)
    }

    static func migratedOpenVPNSettings(
        from maps: [String: [String: Any]],
        currentCipher: String?,
        currentAuth: String?,
        currentPort: Int
    ) -> (cipher: String?, auth: String?, port: Int?) {
        guard let configuration = openVPNSessionConfiguration(from: maps) else {
            return (nil, nil, nil)
        }

        var cipher: String?
        if currentCipher == nil,
            let legacyCipher = configuration[LegacyKey.openVPNCipher] as? String,
            AppConstants.OpenVPNCrypto(rawValue: legacyCipher) != nil
        {
            cipher = legacyCipher
        }

        var auth: String?
        if currentAuth == nil, let legacyAuth = configuration[LegacyKey.openVPNDigest] as? String {
            auth = legacyAuth
        }

        var port: Int?
        if currentPort == 0,
            let remotes = (configuration[LegacyKey.openVPNEndpointProtocols] ?? configuration[LegacyKey.openVPNRemotes]) as? [String]
        {
            let ports = Set(remotes.compactMap { $0.split(separator: ":").last.flatMap { Int($0) } })
            if ports.count == 1 {
                port = ports.first
            }
        }

        return (cipher, auth, port)
    }

    /// OpenVPN and WireGuard had separate legacy small-packets keys that now share one preference.
    /// OpenVPN's carries across for free (same key name); this folds in WireGuard's, only turning
    /// the shared value on, never off.
    static func migratedUseSmallPackets(currentValue: Bool, legacyWireGuardValue: Bool) -> Bool? {
        guard !currentValue, legacyWireGuardValue else {
            return nil
        }

        return true
    }

    /// Must run before the first tunnel-settings build of the launch, or the tunnel reads stale
    /// preferences for one session.
    static func run() {
        guard !AppPreferences.shared.didMigrateLegacyCustomDNS else {
            return
        }

        defer {
            AppPreferences.shared.didMigrateLegacyCustomDNS = true
        }

        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroup) ?? .standard
        let maps = sharedDefaults.dictionary(forKey: LegacyKey.maps) as? [String: [String: Any]] ?? [:]

        let migratedDNS = migratedServers(
            from: maps,
            currentOpenVPN: Client.preferences.openVPNDnsServers,
            currentWireGuard: Client.preferences.wireGuardDnsServers)

        let migratedOpenVPN = migratedOpenVPNSettings(
            from: maps,
            currentCipher: Client.preferences.openVPNCipher,
            currentAuth: Client.preferences.openVPNAuth,
            currentPort: Client.preferences.openVPNPort)

        let migratedSmallPackets = migratedUseSmallPackets(
            currentValue: Client.preferences.useSmallPackets,
            legacyWireGuardValue: sharedDefaults.bool(forKey: LegacyKey.wireGuardUseSmallPackets))

        if migratedDNS.openVPN != nil || migratedDNS.wireGuard != nil || migratedOpenVPN.cipher != nil || migratedOpenVPN.auth != nil
            || migratedOpenVPN.port != nil || migratedSmallPackets != nil
        {
            let preferences = Client.preferences.editable()
            if let wireGuard = migratedDNS.wireGuard {
                preferences.wireGuardDnsServers = wireGuard
            }
            if let openVPN = migratedDNS.openVPN {
                preferences.openVPNDnsServers = openVPN
            }
            if let cipher = migratedOpenVPN.cipher {
                preferences.openVPNCipher = cipher
            }
            if let auth = migratedOpenVPN.auth {
                preferences.openVPNAuth = auth
            }
            if let port = migratedOpenVPN.port {
                preferences.openVPNPort = port
            }
            if let smallPackets = migratedSmallPackets {
                preferences.useSmallPackets = smallPackets
            }
            preferences.commit()

            log.info("Legacy OpenVPN/WireGuard settings migrated into the tunnel preferences")
        }

        // After the commit above, so a crash in between leaves the legacy data intact instead of
        // losing a setting that never reached the preferences.
        sharedDefaults.removeObject(forKey: LegacyKey.maps)
    }
}
