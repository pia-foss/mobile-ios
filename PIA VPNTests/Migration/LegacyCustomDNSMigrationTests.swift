//
//  LegacyCustomDNSMigrationTests.swift
//  PIA VPNTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import XCTest

@testable import PIA_VPN

/// Covers the one change in the legacy-VPN removal that can silently lose a user's setting.
///
/// Custom DNS used to live only in the legacy custom-configuration maps, in two *different* shapes.
/// Those maps are deleted with the rest of the legacy stack, and the PlatformSDK tunnel now reads
/// the preferences — so anything that only ever landed in a map has to be carried across, exactly
/// once, without trampling a newer choice.
final class LegacyCustomDNSMigrationTests: XCTestCase {

    private let wireGuardServers = ["10.0.0.1", "10.0.0.2"]
    private let openVPNServers = ["209.222.18.222"]

    private func wireGuardMap(_ servers: [String]) -> [String: [String: Any]] {
        ["PIAWG": ["customDNSServers": servers]]
    }

    private func openVPNMap(_ servers: [String]) -> [String: [String: Any]] {
        ["PIA": ["sessionConfiguration": ["dnsServers": servers]]]
    }

    // The shape every real legacy install shipped: `OpenVPNProvider.Configuration.sessionConfiguration`,
    // whose `endpointProtocols` are `EndpointProtocol.rawValue` — "<socketType>:<port>", no address.
    private func openVPNConfigurationMap(
        cipher: String? = nil,
        digest: String? = nil,
        endpointProtocols: [String]? = nil,
        nestingKey: String = "sessionConfiguration",
        remotesKey: String = "endpointProtocols"
    ) -> [String: [String: Any]] {
        var configuration: [String: Any] = [:]
        configuration["cipher"] = cipher
        configuration["digest"] = digest
        configuration[remotesKey] = endpointProtocols
        return ["PIA": [nestingKey: configuration]]
    }

    private func endpointProtocol(_ socketTypeAndPort: String) -> String {
        socketTypeAndPort
    }

    // MARK: The two legacy shapes

    func test_wireGuardFlatShapeMigrates() {
        let result = LegacyCustomDNSMigration.migratedServers(
            from: wireGuardMap(wireGuardServers), currentOpenVPN: [], currentWireGuard: [])

        XCTAssertEqual(result.wireGuard, wireGuardServers)
        XCTAssertNil(result.openVPN)
    }

    func test_openVPNNestedShapeMigrates() {
        // OpenVPN nested its list under the `OpenVPN.ProviderConfiguration` Codable shape that
        // TunnelKit synthesised — nothing generates it any more, but installs have it on disk.
        let result = LegacyCustomDNSMigration.migratedServers(
            from: openVPNMap(openVPNServers), currentOpenVPN: [], currentWireGuard: [])

        XCTAssertEqual(result.openVPN, openVPNServers)
        XCTAssertNil(result.wireGuard)
    }

    func test_bothShapesMigrateTogether() {
        var maps = wireGuardMap(wireGuardServers)
        maps.merge(openVPNMap(openVPNServers)) { current, _ in current }

        let result = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: [], currentWireGuard: [])

        XCTAssertEqual(result.wireGuard, wireGuardServers)
        XCTAssertEqual(result.openVPN, openVPNServers)
    }

    // MARK: A newer choice always wins

    func test_populatedPreferenceIsNotOverwritten() {
        // Settings has written these preferences on every DNS change since the PlatformSDK tunnel
        // shipped, so a populated preference is always fresher than the legacy map.
        var maps = wireGuardMap(wireGuardServers)
        maps.merge(openVPNMap(openVPNServers)) { current, _ in current }

        let result = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: ["1.1.1.1"], currentWireGuard: ["8.8.8.8"])

        XCTAssertNil(result.wireGuard)
        XCTAssertNil(result.openVPN)
    }

    func test_onlyTheEmptySideMigrates() {
        var maps = wireGuardMap(wireGuardServers)
        maps.merge(openVPNMap(openVPNServers)) { current, _ in current }

        let result = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: ["1.1.1.1"], currentWireGuard: [])

        XCTAssertEqual(result.wireGuard, wireGuardServers)
        XCTAssertNil(result.openVPN)
    }

    // MARK: Nothing to migrate

    func test_noMapsLeavesPreferencesAlone() {
        let result = LegacyCustomDNSMigration.migratedServers(
            from: [:], currentOpenVPN: [], currentWireGuard: [])

        XCTAssertNil(result.wireGuard)
        XCTAssertNil(result.openVPN)
    }

    func test_emptyLegacyListsDoNotProduceAnEmptyOverride() {
        // The distinction that matters: an empty stored list means "PIA default DNS", not "override
        // with nothing". Writing `[]` through would look identical in the preference but would have
        // been a migration where none was needed.
        var maps = wireGuardMap([])
        maps.merge(openVPNMap([])) { current, _ in current }

        let result = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: [], currentWireGuard: [])

        XCTAssertNil(result.wireGuard)
        XCTAssertNil(result.openVPN)
    }

    func test_unrecognisedShapesAreIgnored() {
        let maps: [String: [String: Any]] = [
            // WireGuard's key holding the wrong type
            "PIAWG": ["customDNSServers": "10.0.0.1"],
            // OpenVPN's list at the top level instead of nested
            "PIA": ["dnsServers": ["209.222.18.222"]]
        ]

        let result = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: [], currentWireGuard: [])

        XCTAssertNil(result.wireGuard)
        XCTAssertNil(result.openVPN)
    }

    func test_unrelatedMapKeysAreIgnored() {
        let maps: [String: [String: Any]] = ["IKEv2": ["customDNSServers": ["10.0.0.1"]]]

        let result = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: [], currentWireGuard: [])

        XCTAssertNil(result.wireGuard)
        XCTAssertNil(result.openVPN)
    }

    // MARK: Idempotence

    func test_migrationIsIdempotent() {
        var maps = wireGuardMap(wireGuardServers)
        maps.merge(openVPNMap(openVPNServers)) { current, _ in current }

        let first = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: [], currentWireGuard: [])

        // Re-running with the migrated values in place must be a no-op, so a repeat (or a retry
        // after a failed commit) cannot disturb what the first pass wrote.
        let second = LegacyCustomDNSMigration.migratedServers(
            from: maps,
            currentOpenVPN: first.openVPN ?? [],
            currentWireGuard: first.wireGuard ?? [])

        XCTAssertNil(second.wireGuard)
        XCTAssertNil(second.openVPN)
    }

    // MARK: OpenVPN cipher, auth digest and remote port

    func test_openVPNCipherAuthAndPortMigrateTogether() {
        let maps = openVPNConfigurationMap(
            cipher: "AES-256-GCM", digest: "SHA1",
            endpointProtocols: [endpointProtocol("UDP:8080"), endpointProtocol("TCP:8080")])

        let result = LegacyCustomDNSMigration.migratedOpenVPNSettings(
            from: maps, currentCipher: nil, currentAuth: nil, currentPort: 0)

        XCTAssertEqual(result.cipher, "AES-256-GCM")
        XCTAssertEqual(result.auth, "SHA256")
        XCTAssertEqual(result.port, 8080)
    }

    func test_legacyDigestIsNormalizedNotCopied() {
        // Auth has no UI: the app always pins SHA256, so a stale pre-normalization digest (e.g. an
        // install from before the old `migrateOVPN()` enforced SHA256) must not be copied verbatim.
        let maps = openVPNConfigurationMap(digest: "SHA1")

        let result = LegacyCustomDNSMigration.migratedOpenVPNSettings(
            from: maps, currentCipher: nil, currentAuth: nil, currentPort: 0)

        XCTAssertEqual(result.auth, "SHA256")
    }

    func test_unsupportedCipherIsIgnored() {
        // Only the two GCM ciphers the PlatformSDK tunnel still supports are carried across; a
        // legacy CBC cipher falls back to the app's default rather than being written verbatim.
        let maps = openVPNConfigurationMap(cipher: "AES-256-CBC")

        let result = LegacyCustomDNSMigration.migratedOpenVPNSettings(
            from: maps, currentCipher: nil, currentAuth: nil, currentPort: 0)

        XCTAssertNil(result.cipher)
    }

    func test_multipleDistinctPortsFallBackToAutomatic() {
        let maps = openVPNConfigurationMap(endpointProtocols: [endpointProtocol("UDP:8080"), endpointProtocol("UDP:9201")])

        let result = LegacyCustomDNSMigration.migratedOpenVPNSettings(
            from: maps, currentCipher: nil, currentAuth: nil, currentPort: 0)

        XCTAssertNil(result.port)
    }

    func test_populatedOpenVPNSettingsAreNotOverwritten() {
        let maps = openVPNConfigurationMap(
            cipher: "AES-256-GCM", digest: "SHA256", endpointProtocols: [endpointProtocol("UDP:8080")])

        let result = LegacyCustomDNSMigration.migratedOpenVPNSettings(
            from: maps, currentCipher: "AES-128-GCM", currentAuth: "SHA1", currentPort: 1198)

        XCTAssertNil(result.cipher)
        XCTAssertNil(result.auth)
        XCTAssertNil(result.port)
    }

    func test_noOpenVPNMapLeavesSettingsAlone() {
        let result = LegacyCustomDNSMigration.migratedOpenVPNSettings(
            from: [:], currentCipher: nil, currentAuth: nil, currentPort: 0)

        XCTAssertNil(result.cipher)
        XCTAssertNil(result.auth)
        XCTAssertNil(result.port)
    }

    // MARK: The Kape-transitional shape (nested under "configuration", remotes carry an address)

    func test_transitionalConfigurationShapeMigratesDNS() {
        let maps: [String: [String: Any]] = ["PIA": ["configuration": ["dnsServers": openVPNServers]]]

        let result = LegacyCustomDNSMigration.migratedServers(
            from: maps, currentOpenVPN: [], currentWireGuard: [])

        XCTAssertEqual(result.openVPN, openVPNServers)
    }

    func test_transitionalConfigurationShapeMigratesCipherAndPort() {
        let maps = openVPNConfigurationMap(
            cipher: "AES-256-GCM",
            endpointProtocols: ["209.222.18.222:UDP:8080"],
            nestingKey: "configuration",
            remotesKey: "remotes")

        let result = LegacyCustomDNSMigration.migratedOpenVPNSettings(
            from: maps, currentCipher: nil, currentAuth: nil, currentPort: 0)

        XCTAssertEqual(result.cipher, "AES-256-GCM")
        XCTAssertEqual(result.auth, "SHA256")
        XCTAssertEqual(result.port, 8080)
    }

    // MARK: Use Small Packets

    func test_wireGuardSmallPacketsMigratesWhenSharedPreferenceIsOff() {
        let result = LegacyCustomDNSMigration.migratedUseSmallPackets(currentValue: false, legacyWireGuardValue: true)

        XCTAssertEqual(result, true)
    }

    func test_wireGuardSmallPacketsOffLeavesSharedPreferenceAlone() {
        let result = LegacyCustomDNSMigration.migratedUseSmallPackets(currentValue: false, legacyWireGuardValue: false)

        XCTAssertNil(result)
    }

    func test_sharedPreferenceAlreadyOnIsNeverTurnedOff() {
        // OpenVPN's "UseSmallPackets" key is unchanged, so it already carried across. A WireGuard
        // legacy value of false must not disable what OpenVPN's toggle already turned on.
        let result = LegacyCustomDNSMigration.migratedUseSmallPackets(currentValue: true, legacyWireGuardValue: false)

        XCTAssertNil(result)
    }
}
