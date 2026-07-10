//
//  ServersPingerTests.swift
//  PIALibraryTests
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

import XCTest

@testable import PIALibrary

final class ServersPingerTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // MockVPNProvider reports "Mock" as VPN type, so Server.addresses()
        // resolves to iKEv2AddressesForUDP.
        Client.providers.vpnProvider = MockVPNProvider()
        Client.database.transient.vpnStatus = .disconnected
    }

    override func tearDown() {
        Client.database.transient.vpnStatus = .disconnected
        super.tearDown()
    }

    private func makeServers(count: Int) -> [Server] {
        return (0..<count).map { index in
            Server(
                serial: "serial-\(index)",
                name: "Server \(index)",
                country: "us",
                hostname: "server\(index).example.com",
                iKEv2AddressesForUDP: [Server.ServerAddressIP(ip: "10.0.0.\(index)", cn: "cn", van: false)],
                pingAddress: nil,
                regionIdentifier: "region-\(index)"
            )
        }
    }

    func testConcurrentPingJoinsInflightPass() async {
        let counter = Counter()
        let pinger = ServersPinger(
            pinger: MockPinger { _, _, _ in
                await counter.enter()
                try? await Task.sleep(nanoseconds: 200_000_000)
                await counter.leave()
                return 42
            })
        let servers = makeServers(count: 4)

        async let first = pinger.ping(withDestinations: servers)
        try? await Task.sleep(nanoseconds: 50_000_000)
        async let second = pinger.ping(withDestinations: servers)

        let results = await [first, second]
        XCTAssertEqual(results, [.completed, .completed])

        // The second call joined the in-flight pass instead of starting a new one.
        let invocations = await counter.invocations
        XCTAssertEqual(invocations, servers.count)
    }

    func testResetCancelsInflightPass() async {
        let pinger = ServersPinger(
            pinger: MockPinger { _, _, _ in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 20_000_000)
                }
                return nil
            })
        let servers = makeServers(count: 2)
        let start = Date()

        async let result = pinger.ping(withDestinations: servers)
        try? await Task.sleep(nanoseconds: 100_000_000)
        await pinger.reset()

        let outcome = await result
        XCTAssertEqual(outcome, .cancelled)
        XCTAssertLessThan(Date().timeIntervalSince(start), 3)
    }

    func testPingsAreWindowed() async {
        let counter = Counter()
        let pinger = ServersPinger(
            pinger: MockPinger { _, _, _ in
                await counter.enter()
                try? await Task.sleep(nanoseconds: 20_000_000)
                await counter.leave()
                return 10
            })
        let servers = makeServers(count: 100)

        let result = await pinger.ping(withDestinations: servers)
        XCTAssertEqual(result, .completed)

        let invocations = await counter.invocations
        XCTAssertEqual(invocations, servers.count)
        let peak = await counter.highWaterMark
        XCTAssertLessThanOrEqual(peak, 16)
    }

    func testPingIsSkippedWhileVPNActive() async {
        Client.database.transient.vpnStatus = .connected
        let pinger = ServersPinger(pinger: MockPinger { _, _, _ in 1 })

        let result = await pinger.ping(withDestinations: makeServers(count: 1))
        XCTAssertEqual(result, .skippedVPNActive)
    }
}

private class MockPinger: Pinger {
    private let callback: (String, UInt16, TimeInterval) async -> Int?

    init(callback: @escaping (String, UInt16, TimeInterval) async -> Int?) {
        self.callback = callback
    }

    func ping(ip: String, port: UInt16, timeout: TimeInterval) async -> Int? {
        return await callback(ip, port, timeout)
    }
}

private actor Counter {
    private(set) var invocations = 0
    private(set) var highWaterMark = 0
    private var active = 0

    func enter() {
        invocations += 1
        active += 1
        highWaterMark = max(highWaterMark, active)
    }

    func leave() {
        active -= 1
    }
}
