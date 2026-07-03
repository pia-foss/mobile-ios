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

@Suite("PIATunnelSharedState.State Codable")
struct PIATunnelSharedStateTests {

    private func roundTrip(_ state: PIATunnelSharedState.State) throws -> PIATunnelSharedState.State {
        let data = try JSONEncoder().encode(state)
        return try JSONDecoder().decode(PIATunnelSharedState.State.self, from: data)
    }

    @Test("DNS servers survive an encode/decode round-trip")
    func dnsRoundTrip() throws {
        let state = PIATunnelSharedState.State(
            selectedProtocol: .wireGuard,
            openVPN: .init(dnsServers: ["8.8.8.8", "8.8.4.4"]),
            wireGuard: .init(dnsServers: ["1.1.1.1", "1.0.0.1"])
        )

        let decoded = try roundTrip(state)

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
        let state = PIATunnelSharedState.State(openVPN: openVPN, wireGuard: wireGuard)

        let decoded = try roundTrip(state)

        #expect(decoded.openVPN == openVPN)
        #expect(decoded.wireGuard == wireGuard)
    }

    @Test("Default state has empty DNS lists (PIA-default / server-pushed behaviour)")
    func defaultsAreEmpty() {
        let state = PIATunnelSharedState.State()
        #expect(state.openVPN.dnsServers.isEmpty)
        #expect(state.wireGuard.dnsServers.isEmpty)
    }

    @Test("An older payload missing the settings keys decodes to defaults")
    func backwardCompatibleDecode() throws {
        // Simulates a state file written before the OpenVPN / WireGuard settings existed.
        let legacyJSON = Data("{}".utf8)
        let decoded = try JSONDecoder().decode(PIATunnelSharedState.State.self, from: legacyJSON)
        #expect(decoded.openVPN.dnsServers.isEmpty)
        #expect(decoded.wireGuard.dnsServers.isEmpty)
    }

    @Test("activeConnection survives an encode/decode round-trip")
    func activeConnectionRoundTrip() throws {
        let connection = PIATunnelSharedState.ActiveConnection(
            protocol: .openVPN,
            serverId: "us_chicago",
            resolvedTransport: .tcp,
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let state = PIATunnelSharedState.State(activeConnection: connection)

        let decoded = try roundTrip(state)

        #expect(decoded.activeConnection == connection)
        #expect(decoded.activeConnection?.protocol == .openVPN)
        #expect(decoded.activeConnection?.serverId == "us_chicago")
        #expect(decoded.activeConnection?.resolvedTransport == .tcp)
    }

    @Test("activeConnection defaults to nil and an older payload decodes to nil")
    func activeConnectionDefaultsNil() throws {
        #expect(PIATunnelSharedState.State().activeConnection == nil)

        let legacyJSON = Data("{}".utf8)
        let decoded = try JSONDecoder().decode(PIATunnelSharedState.State.self, from: legacyJSON)
        #expect(decoded.activeConnection == nil)
    }

    @Test("tunnelStatus survives an encode/decode round-trip")
    func tunnelStatusRoundTrip() throws {
        let state = PIATunnelSharedState.State(tunnelStatus: .reconnecting)
        #expect(try roundTrip(state).tunnelStatus == .reconnecting)
    }

    @Test("tunnelStatus defaults to nil and an older payload (no key) decodes to nil")
    func tunnelStatusDefaultsNil() throws {
        #expect(PIATunnelSharedState.State().tunnelStatus == nil)

        let legacyJSON = Data("{}".utf8)
        let decoded = try JSONDecoder().decode(PIATunnelSharedState.State.self, from: legacyJSON)
        #expect(decoded.tunnelStatus == nil)
    }

    @Test("A payload written before resolvedTransport existed decodes to .udp")
    func resolvedTransportBackwardCompat() throws {
        // An active-connection blob missing the transport key must not fail the whole state decode;
        // it defaults to `.udp` (WireGuard is always UDP; OpenVPN's primary transport is UDP).
        let legacyJSON = Data(#"{"protocol":"wireGuard","serverId":"us_chicago","updatedAt":0}"#.utf8)
        let decoded = try JSONDecoder().decode(PIATunnelSharedState.ActiveConnection.self, from: legacyJSON)
        #expect(decoded.resolvedTransport == .udp)
        #expect(decoded.protocol == .wireGuard)
    }
}
