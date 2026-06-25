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
            openVPNDnsServers: ["8.8.8.8", "8.8.4.4"],
            wireGuardDnsServers: ["1.1.1.1", "1.0.0.1"]
        )

        let decoded = try roundTrip(state)

        #expect(decoded.openVPNDnsServers == ["8.8.8.8", "8.8.4.4"])
        #expect(decoded.wireGuardDnsServers == ["1.1.1.1", "1.0.0.1"])
    }

    @Test("Default state has empty DNS lists (PIA-default / server-pushed behaviour)")
    func defaultsAreEmpty() {
        let state = PIATunnelSharedState.State()
        #expect(state.openVPNDnsServers.isEmpty)
        #expect(state.wireGuardDnsServers.isEmpty)
    }

    @Test("An older payload missing the DNS keys decodes to empty lists")
    func backwardCompatibleDecode() throws {
        // Simulates a state file written before the DNS fields existed.
        let legacyJSON = Data("{}".utf8)
        let decoded = try JSONDecoder().decode(PIATunnelSharedState.State.self, from: legacyJSON)
        #expect(decoded.openVPNDnsServers.isEmpty)
        #expect(decoded.wireGuardDnsServers.isEmpty)
    }
}
