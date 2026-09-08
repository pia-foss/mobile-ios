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
        ["PIA": ["configuration": ["dnsServers": servers]]]
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
}
