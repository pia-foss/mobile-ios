//
//  PIATunnelSharedStateTests.swift
//  PIALibrary
//
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

import Foundation
import Testing

@testable import PIALibrary

@Suite("PIATunnelSharedState slices Codable")
struct PIATunnelSharedStateCodableTests {

    private func roundTrip<Value: Codable>(_ value: Value) throws -> Value {
        let data = try JSONEncoder().encode(value)
        return try JSONDecoder().decode(Value.self, from: data)
    }

    // MARK: - Config

    @Test("DNS servers survive an encode/decode round-trip")
    func dnsRoundTrip() throws {
        let config = PIATunnelSharedState.Config(
            selectedProtocol: .wireGuard,
            openVPN: .init(dnsServers: ["8.8.8.8", "8.8.4.4"]),
            wireGuard: .init(dnsServers: ["1.1.1.1", "1.0.0.1"])
        )

        let decoded = try roundTrip(config)

        #expect(decoded.openVPN.dnsServers == ["8.8.8.8", "8.8.4.4"])
        #expect(decoded.wireGuard.dnsServers == ["1.1.1.1", "1.0.0.1"])
    }

    @Test("OpenVPN / WireGuard settings survive an encode/decode round-trip")
    func settingsRoundTrip() throws {
        let openVPN = PIATunnelSharedState.OpenVPNSettings(
            caCertificate: "CERT", username: "user", password: "pass",
            ovpnConfig: "cipher AES-128-GCM\nauth SHA256", port: 8443,
            transport: .tcp, mtu: 1350, dnsServers: ["8.8.8.8"])
        let wireGuard = PIATunnelSharedState.WireGuardSettings(
            mtu: 1280, token: "tok", dnsServers: ["1.1.1.1"])
        let config = PIATunnelSharedState.Config(openVPN: openVPN, wireGuard: wireGuard)

        let decoded = try roundTrip(config)

        #expect(decoded.openVPN == openVPN)
        #expect(decoded.wireGuard == wireGuard)
    }

    @Test("Default config has empty DNS lists (PIA-default / server-pushed behaviour)")
    func defaultsAreEmpty() {
        let config = PIATunnelSharedState.Config()
        #expect(config.openVPN.dnsServers.isEmpty)
        #expect(config.wireGuard.dnsServers.isEmpty)
    }

    @Test("Measured latencies survive an encode/decode round-trip")
    func latenciesRoundTrip() throws {
        let config = PIATunnelSharedState.Config(latencyByServerId: ["us_chicago": 42, "de_berlin": 87])
        #expect(try roundTrip(config).latencyByServerId == ["us_chicago": 42, "de_berlin": 87])
    }

    @Test("A config payload missing every key decodes to defaults")
    func configBackwardCompatibleDecode() throws {
        // Also covers the first read after the split, when no config file exists yet.
        let decoded = try JSONDecoder().decode(PIATunnelSharedState.Config.self, from: Data("{}".utf8))
        #expect(decoded.selectedLocationId == nil)
        #expect(decoded.selectedProtocol == .automatic)
        #expect(decoded.openVPN.dnsServers.isEmpty)
        #expect(decoded.wireGuard.dnsServers.isEmpty)
        #expect(decoded.latencyByServerId.isEmpty)
    }

    // MARK: - ServersCache

    @Test("An empty servers cache decodes to no servers and no fetch date")
    func serversCacheDefaults() throws {
        #expect(PIATunnelSharedState.ServersCache().servers.isEmpty)
        #expect(PIATunnelSharedState.ServersCache().serversFetchedAt == nil)

        let decoded = try JSONDecoder().decode(PIATunnelSharedState.ServersCache.self, from: Data("{}".utf8))
        #expect(decoded.servers.isEmpty)
        #expect(decoded.serversFetchedAt == nil)
    }

    @Test("The servers-cache fetch date survives an encode/decode round-trip")
    func serversCacheFetchDateRoundTrip() throws {
        let fetchedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let decoded = try roundTrip(PIATunnelSharedState.ServersCache(serversFetchedAt: fetchedAt))
        #expect(decoded.serversFetchedAt == fetchedAt)
    }

    // MARK: - Status

    @Test("activeConnection survives an encode/decode round-trip")
    func activeConnectionRoundTrip() throws {
        let connection = PIATunnelSharedState.ActiveConnection(
            protocol: .openVPN,
            serverId: "us_chicago",
            resolvedTransport: .tcp,
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let decoded = try roundTrip(PIATunnelSharedState.Status(activeConnection: connection))

        #expect(decoded.activeConnection == connection)
        #expect(decoded.activeConnection?.protocol == .openVPN)
        #expect(decoded.activeConnection?.serverId == "us_chicago")
        #expect(decoded.activeConnection?.resolvedTransport == .tcp)
    }

    @Test("activeConnection defaults to nil and an older payload decodes to nil")
    func activeConnectionDefaultsNil() throws {
        #expect(PIATunnelSharedState.Status().activeConnection == nil)

        let decoded = try JSONDecoder().decode(PIATunnelSharedState.Status.self, from: Data("{}".utf8))
        #expect(decoded.activeConnection == nil)
    }

    @Test("tunnelStatus survives an encode/decode round-trip")
    func tunnelStatusRoundTrip() throws {
        #expect(try roundTrip(PIATunnelSharedState.Status(tunnelStatus: .reconnecting)).tunnelStatus == .reconnecting)
    }

    @Test("tunnelStatus defaults to nil and an older payload (no key) decodes to nil")
    func tunnelStatusDefaultsNil() throws {
        #expect(PIATunnelSharedState.Status().tunnelStatus == nil)

        let decoded = try JSONDecoder().decode(PIATunnelSharedState.Status.self, from: Data("{}".utf8))
        #expect(decoded.tunnelStatus == nil)
    }

    @Test("A payload written before resolvedTransport existed decodes to .udp")
    func resolvedTransportBackwardCompat() throws {
        // An active-connection blob missing the transport key must not fail the whole status decode;
        // it defaults to `.udp` (WireGuard is always UDP; OpenVPN's primary transport is UDP).
        let legacyJSON = Data(#"{"protocol":"wireGuard","serverId":"us_chicago","updatedAt":0}"#.utf8)
        let decoded = try JSONDecoder().decode(PIATunnelSharedState.ActiveConnection.self, from: legacyJSON)
        #expect(decoded.resolvedTransport == .udp)
        #expect(decoded.protocol == .wireGuard)
    }
}

/// Covers `Store`'s read-modify-write behaviour, which is what keeps two writers in one process from
/// losing each other's changes. Uses an injected temp directory: an App Group container is not
/// reachable from a unit-test process (`containerURL(forSecurityApplicationGroupIdentifier:)`
/// returns nil), so the production stores can't be exercised directly.
@Suite("PIATunnelSharedState.Store")
struct PIATunnelSharedStateStoreTests {

    /// A store rooted in a fresh temp directory, plus that directory for cleanup/inspection.
    private func makeStore(
        fileName: String = "slice.json"
    ) throws -> (store: PIATunnelSharedState.Store<PIATunnelSharedState.Config>, directory: URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PIATunnelSharedStateTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let store = PIATunnelSharedState.Store(fileName: fileName, directory: { directory }) {
            PIATunnelSharedState.Config()
        }
        return (store, directory)
    }

    @Test("A missing file reads as defaults")
    func missingFileReadsDefaults() throws {
        let (store, directory) = try makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        #expect(store.read().selectedProtocol == .automatic)
        #expect(store.read().latencyByServerId.isEmpty)
    }

    @Test("A written value reads back")
    func writeThenRead() throws {
        let (store, directory) = try makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.write(PIATunnelSharedState.Config(selectedLocationId: "us_chicago", selectedProtocol: .wireGuard))

        #expect(store.read().selectedLocationId == "us_chicago")
        #expect(store.read().selectedProtocol == .wireGuard)
    }

    @Test("Deleting returns the slice to defaults")
    func deleteReturnsToDefaults() throws {
        let (store, directory) = try makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.write(PIATunnelSharedState.Config(selectedLocationId: "us_chicago"))
        store.delete()

        #expect(store.read().selectedLocationId == nil)
    }

    @Test("Deleting a slice that was never written is not an error")
    func deleteMissingFile() throws {
        let (store, directory) = try makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.delete()

        #expect(store.read().selectedLocationId == nil)
    }

    @Test("mutate returning false leaves the persisted value untouched")
    func mutateCanSkipTheWrite() throws {
        let (store, directory) = try makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.write(PIATunnelSharedState.Config(selectedLocationId: "us_chicago"))
        store.mutate { config in
            config.selectedLocationId = "de_berlin"
            return false
        }

        #expect(store.read().selectedLocationId == "us_chicago")
    }

    /// The regression test for the lost-update race this split was made to fix: concurrent
    /// read-modify-writes each touching a *different* key must all survive. Before `mutate` held a
    /// lock across the whole cycle, writers built on stale snapshots and dropped each other's keys.
    @Test("Concurrent mutations of one slice don't lose updates")
    func concurrentMutationsDoNotLoseUpdates() throws {
        let (store, directory) = try makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        let writers = 64
        DispatchQueue.concurrentPerform(iterations: writers) { index in
            store.mutate { config in
                config.latencyByServerId["server_\(index)"] = index
                return true
            }
        }

        let latencies = store.read().latencyByServerId
        #expect(latencies.count == writers)
        for index in 0..<writers {
            #expect(latencies["server_\(index)"] == index)
        }
    }

    @Test("Concurrent readers never observe a partially written slice")
    func concurrentReadsAreNeverTorn() throws {
        let (store, directory) = try makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        // Big enough that an unprotected read could catch a write mid-flight.
        let latencies = Dictionary(uniqueKeysWithValues: (0..<500).map { ("server_\($0)", $0) })
        store.write(PIATunnelSharedState.Config(latencyByServerId: latencies))

        // Assertions run on the calling thread: `#expect` inside `concurrentPerform` executes outside
        // the test's task context, where Swift Testing can't attribute a failure.
        let observed = Observed()
        DispatchQueue.concurrentPerform(iterations: 32) { index in
            if index.isMultiple(of: 2) {
                store.write(PIATunnelSharedState.Config(latencyByServerId: latencies))
            } else {
                observed.record(store.read().latencyByServerId.count)
            }
        }

        // Every read saw either the full map or the default — never a half-decoded one.
        #expect(observed.counts.allSatisfy { $0 == 0 || $0 == latencies.count })
    }

    /// Collects counts from concurrent readers.
    private final class Observed: @unchecked Sendable {
        private let lock = NSLock()
        private var storage: [Int] = []

        var counts: [Int] {
            lock.lock()
            defer { lock.unlock() }
            return storage
        }

        func record(_ count: Int) {
            lock.lock()
            storage.append(count)
            lock.unlock()
        }
    }

    @Test("Slices with different file names are independent")
    func slicesAreIndependent() throws {
        let (config, directory) = try makeStore(fileName: "config.json")
        defer { try? FileManager.default.removeItem(at: directory) }
        let status = PIATunnelSharedState.Store(fileName: "status.json", directory: { directory }) {
            PIATunnelSharedState.Status()
        }

        // Stands in for the race across the process boundary: the app rewriting its config while the
        // extension writes the tunnel's status. Separate files, so neither can drop the other.
        config.write(PIATunnelSharedState.Config(selectedLocationId: "us_chicago"))
        status.write(PIATunnelSharedState.Status(tunnelStatus: .connected))
        config.write(PIATunnelSharedState.Config(selectedLocationId: "de_berlin"))

        #expect(config.read().selectedLocationId == "de_berlin")
        #expect(status.read().tunnelStatus == .connected)
    }
}
