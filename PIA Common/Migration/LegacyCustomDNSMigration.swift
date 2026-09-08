//
//  LegacyCustomDNSMigration.swift
//  PIA Common
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: LegacyCustomDNSMigration.self)

/// One-time backfill of the custom DNS resolvers an install chose before
/// `openVPNDnsServers` / `wireGuardDnsServers` existed.
///
/// Custom DNS used to live only in the legacy custom-configuration maps, in two different shapes.
/// Those maps are going away with the rest of the legacy VPN stack, and the PlatformSDK tunnel now
/// reads the preferences instead — so anything that only ever landed in a map has to be carried
/// across, or the user silently drops back to server-pushed DNS.
///
/// The preferences win when both are populated: Settings has been writing them on every change
/// since the PlatformSDK tunnel shipped, so they are the fresher of the two.
enum LegacyCustomDNSMigration {

    /// The two shapes the legacy maps used. WireGuard kept a flat list; OpenVPN nested it under the
    /// `OpenVPN.ProviderConfiguration` Codable shape that TunnelKit synthesised.
    ///
    /// Read straight out of the app-group defaults: `Client.database.plain` is internal to
    /// PIALibrary, and the typed `vpnCustomConfiguration(for:)` accessor cannot help — the
    /// PlatformSDK profile's `parsedCustomConfiguration` returns `nil` by design. This is
    /// throwaway migration code reading a key that is being deleted, so reaching past the store is
    /// the lesser evil against widening PIALibrary's public surface for it.
    private enum LegacyKey {
        static let maps = "VPNCustomConfigurationMaps"
        static let wireGuardMap = "PIAWG"
        static let openVPNMap = "PIA"
        static let wireGuardServers = "customDNSServers"
        static let openVPNConfiguration = "configuration"
        static let openVPNServers = "dnsServers"
    }

    /// The DNS servers a legacy map should contribute, given what the preferences already hold.
    ///
    /// Pure, so the shape handling can be tested exhaustively without the app-group defaults,
    /// `AppPreferences` or `Client.preferences`. `nil` for a protocol means "leave the preference
    /// alone" — either it is already populated (a populated preference is always the more recent
    /// choice) or the legacy map has nothing usable for it.
    static func migratedServers(
        from maps: [String: [String: Any]],
        currentOpenVPN: [String],
        currentWireGuard: [String]
    ) -> (openVPN: [String]?, wireGuard: [String]?) {
        var wireGuard: [String]?
        var openVPN: [String]?

        // WireGuard kept a flat list.
        if currentWireGuard.isEmpty,
            let servers = maps[LegacyKey.wireGuardMap]?[LegacyKey.wireGuardServers] as? [String],
            !servers.isEmpty
        {
            wireGuard = servers
        }

        // OpenVPN nested it under the `OpenVPN.ProviderConfiguration` Codable shape.
        if currentOpenVPN.isEmpty,
            let configuration = maps[LegacyKey.openVPNMap]?[LegacyKey.openVPNConfiguration] as? [String: Any],
            let servers = configuration[LegacyKey.openVPNServers] as? [String],
            !servers.isEmpty
        {
            openVPN = servers
        }

        return (openVPN: openVPN, wireGuard: wireGuard)
    }

    /// Copies any legacy custom DNS into the preferences, once.
    ///
    /// Must run before the first tunnel-settings build of the launch: the tunnel reads the
    /// preferences, so a late backfill means one session on the wrong resolvers.
    static func run() {
        guard !AppPreferences.shared.didMigrateLegacyCustomDNS else {
            return
        }

        defer { AppPreferences.shared.didMigrateLegacyCustomDNS = true }

        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroup) ?? .standard
        guard let maps = sharedDefaults.dictionary(forKey: LegacyKey.maps) as? [String: [String: Any]] else {
            return
        }

        let migrated = migratedServers(
            from: maps,
            currentOpenVPN: Client.preferences.openVPNDnsServers,
            currentWireGuard: Client.preferences.wireGuardDnsServers)

        if migrated.openVPN != nil || migrated.wireGuard != nil {
            let preferences = Client.preferences.editable()
            if let wireGuard = migrated.wireGuard {
                preferences.wireGuardDnsServers = wireGuard
            }
            if let openVPN = migrated.openVPN {
                preferences.openVPNDnsServers = openVPN
            }
            preferences.commit()

            log.info("Legacy custom DNS migrated into the tunnel preferences")
        }

        // The maps are the last of the legacy custom-configuration store: nothing reads them any
        // more, and nothing will ever write them again. Drop the blob once its DNS has been carried
        // across — or found to hold nothing worth carrying — rather than leaving it in every
        // upgraded install's app group forever.
        //
        // Deliberately after the commit above, so a crash in between leaves the legacy data intact
        // rather than losing a setting that never reached the preferences.
        sharedDefaults.removeObject(forKey: LegacyKey.maps)
    }
}
