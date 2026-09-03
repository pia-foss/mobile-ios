//
//  ServersBundleAmneziaTests.swift
//  PIALibrary
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Testing

@testable import PIALibrary

@Suite("ServersBundle AmneziaWG parsing")
struct ServersBundleAmneziaTests {

    private static func payload(regionServers: String) -> String {
        """
        {
          "groups": {
            "wg": [{ "name": "wireguard", "ports": [1337] }],
            "ovpnudp": [{ "name": "openvpn_udp", "ports": [8080] }],
            "ovpntcp": [{ "name": "openvpn_tcp", "ports": [443] }],
            "ikev2": [{ "name": "ikev2", "ports": [500] }]
          },
          "regions": [
            {
              "id": "us_seattle",
              "name": "US Seattle",
              "country": "US",
              "dns": "us-seattle.pvt.site",
              "auto_region": true,
              "port_forward": false,
              "geo": false,
              "offline": false,
              "servers": { \(regionServers) }
            }
          ]
        }
        """
    }

    private static let wireGuardAndAmnezia = """
        "wg": [{ "ip": "1.1.1.1", "cn": "Server-1" }],
        "awg": [
          { "ip": "2.2.2.2", "cn": "Server-2", "port": 1338 },
          { "ip": "3.3.3.3", "cn": "Server-3", "port": 1338 }
        ]
        """

    private static let wireGuardOnly = """
        "wg": [{ "ip": "1.1.1.1", "cn": "Server-1" }]
        """

    @Test("awg addresses are parsed with their own port")
    func parsesAmneziaAddresses() throws {
        let bundle = try #require(ServersBundle.parse(from: Self.payload(regionServers: Self.wireGuardAndAmnezia)))
        let server = try #require(bundle.servers.first)

        let amnezia = try #require(server.amneziaAddressesForUDP)
        #expect(amnezia.map(\.ip) == ["2.2.2.2", "3.3.3.3"])
        #expect(amnezia.map(\.cn) == ["Server-2", "Server-3"])
        #expect(amnezia.allSatisfy { $0.port == 1338 })
    }

    @Test("awg addresses are distinct from wg addresses")
    func amneziaIsNotWireGuard() throws {
        let bundle = try #require(ServersBundle.parse(from: Self.payload(regionServers: Self.wireGuardAndAmnezia)))
        let server = try #require(bundle.servers.first)

        #expect(server.wireGuardAddressesForUDP?.map(\.ip) == ["1.1.1.1"])
        #expect(server.wireGuardAddressesForUDP?.first?.port == nil)
    }

    @Test("a region without awg still parses")
    func regionWithoutAmnezia() throws {
        let bundle = try #require(ServersBundle.parse(from: Self.payload(regionServers: Self.wireGuardOnly)))
        let server = try #require(bundle.servers.first)

        #expect(server.amneziaAddressesForUDP == nil)
        #expect(server.wireGuardAddressesForUDP?.isEmpty == false)
    }

    @Test("keys the client does not know are ignored rather than failing the parse")
    func toleratesUnknownKeys() throws {
        let withUnknowns = """
            "wg": [{ "ip": "1.1.1.1", "cn": "Server-1", "future_flag": true }],
            "awg": [{ "ip": "2.2.2.2", "cn": "Server-2", "port": 1338, "mtu": 1280 }],
            "quantum": [{ "ip": "4.4.4.4", "cn": "Server-4" }]
            """
        let bundle = try #require(ServersBundle.parse(from: Self.payload(regionServers: withUnknowns)))
        let server = try #require(bundle.servers.first)

        #expect(server.amneziaAddressesForUDP?.first?.port == 1338)
        #expect(server.wireGuardAddressesForUDP?.first?.ip == "1.1.1.1")
    }

    @Test("awg addresses survive an encode/decode round trip")
    func roundTrip() throws {
        let bundle = try #require(ServersBundle.parse(from: Self.payload(regionServers: Self.wireGuardAndAmnezia)))
        let original = try #require(bundle.servers.first)

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Server.self, from: encoded)

        #expect(decoded.amneziaAddressesForUDP?.map(\.ip) == ["2.2.2.2", "3.3.3.3"])
        #expect(decoded.amneziaAddressesForUDP?.allSatisfy { $0.port == 1338 } == true)
    }

    @Test("amnezia addresses do not make a region usable on their own")
    func amneziaDoesNotCountAsEndpoints() throws {
        let amneziaOnly = try #require(
            ServersBundle.parse(
                from: Self.payload(regionServers: #""awg": [{ "ip": "2.2.2.2", "cn": "Server-2", "port": 1338 }]"#)))
        let server = try #require(amneziaOnly.servers.first)

        #expect(server.hasEndpoints(for: KapePlatformSDKVPNType.wireGuard.rawValue) == false)
        #expect(server.hasEndpoints(for: KapePlatformSDKVPNType.automatic.rawValue) == false)
    }
}
