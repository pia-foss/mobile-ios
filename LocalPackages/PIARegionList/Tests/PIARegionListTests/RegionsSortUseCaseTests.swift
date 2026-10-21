//
//  RegionsSortUseCaseTests.swift
//  PIARegionListTests
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
import PIARegionListDomain
import Testing

private struct ServerStub: SortableRegion, Equatable {
    let name: String
    var pingTime: Int?
    var geo = false
    var dipToken: String?
    var vpnTypes: Set<String> = ["wireguard"]
    var isFavorite = false

    func hasEndpoints(for vpnType: String) -> Bool { vpnTypes.contains(vpnType) }
}

struct RegionsSortUseCaseTests {
    private let sut = RegionsSortUseCase()

    private let austria = ServerStub(name: "Austria", pingTime: 80)
    private let brazil = ServerStub(name: "Brazil", pingTime: nil, isFavorite: true)
    private let chile = ServerStub(name: "Chile", pingTime: 20, geo: true)
    private let dip = ServerStub(name: "DIP", pingTime: 10, dipToken: "token", vpnTypes: [])
    private let openVPNOnly = ServerStub(name: "Egypt", pingTime: 5, vpnTypes: ["openvpn"])

    private func sorted(_ sort: RegionFilter, showGeoServers: Bool = true) -> [String] {
        sut([brazil, chile, openVPNOnly, austria, dip], sort: sort, showGeoServers: showGeoServers, vpnType: "wireguard", isFavorite: \.isFavorite)
            .map(\.name)
    }

    @Test("Sorts by name")
    func byName() {
        #expect(sorted(.name) == ["Austria", "Brazil", "Chile", "DIP"])
    }

    @Test("Sorts by latency, unknown latency last")
    func byLatency() {
        #expect(sorted(.latency) == ["DIP", "Chile", "Austria", "Brazil"])
    }

    @Test("Sorts favorites first")
    func byFavorite() {
        #expect(sorted(.favorite) == ["Brazil", "Austria", "Chile", "DIP"])
    }

    @Test("Hides geo servers when disabled")
    func hidesGeo() {
        #expect(sorted(.name, showGeoServers: false) == ["Austria", "Brazil", "DIP"])
    }

    @Test("Search is a case-insensitive contains", arguments: [("ra", ["Brazil"]), ("A", ["Austria", "Brazil"]), ("", ["Austria", "Brazil"])])
    func search(text: String, expected: [String]) {
        #expect(sut.search(text, in: [austria, brazil]).map(\.name) == expected)
    }

    @Test("Dedicated IPs are always reachable, others need endpoints")
    func protocolFilter() {
        #expect(ProtocolFilter.isReachable(dipToken: "token", vpnType: "wireguard", hasEndpoints: { _ in false }))
        #expect(!ProtocolFilter.isReachable(dipToken: nil, vpnType: "wireguard", hasEndpoints: { _ in false }))
        #expect(ProtocolFilter.isReachable(dipToken: nil, vpnType: "wireguard", hasEndpoints: { $0 == "wireguard" }))
    }
}
