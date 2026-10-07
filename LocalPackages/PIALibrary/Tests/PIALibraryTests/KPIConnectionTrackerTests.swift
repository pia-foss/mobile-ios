//
//  KPIConnectionTrackerTests.swift
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

import NetworkExtension
import Testing

@testable import PIALibrary

@Suite("KPIConnectionTracker")
struct KPIConnectionTrackerTests {

    private func events(for statuses: [KPIConnectionStatus], from initial: KPIConnectionStatus? = .notConnected) -> [KPIConnectionEvent] {
        var tracker = KPIConnectionTracker(status: initial)
        return statuses.compactMap { tracker.update(to: $0) }
    }

    // MARK: Events

    @Test("A successful connection reports an attempt and then an established event")
    func successfulConnection() {
        #expect(events(for: [.connecting, .connected]) == [.vpnConnectionAttempt, .vpnConnectionEstablished])
    }

    @Test("A connection that ends before connecting is reported as cancelled")
    func cancelledConnection() {
        #expect(events(for: [.connecting, .notConnected]) == [.vpnConnectionAttempt, .vpnConnectionCancelled])
    }

    @Test("Disconnecting an established connection reports nothing")
    func disconnectAfterConnected() {
        #expect(events(for: [.connecting, .connected, .notConnected]) == [.vpnConnectionAttempt, .vpnConnectionEstablished])
    }

    @Test("A mid-session reconnect is reported as an attempt")
    func reconnect() {
        #expect(events(for: [.reconnecting, .connected], from: .connected) == [.vpnConnectionAttempt, .vpnConnectionEstablished])
    }

    @Test("A reconnect that gives up is not reported as cancelled")
    func reconnectThenDisconnect() {
        #expect(events(for: [.reconnecting, .notConnected], from: .connected) == [.vpnConnectionAttempt])
    }

    @Test("Pausing and resuming reports nothing")
    func paused() {
        #expect(events(for: [.paused, .connected, .paused, .notConnected], from: .connected).isEmpty)
    }

    @Test("Connected without a reported attempt reports nothing")
    func connectedWithoutAttempt() {
        #expect(events(for: [.connected]).isEmpty)
    }

    @Test("Repeated statuses are reported once")
    func repeatedStatuses() {
        #expect(events(for: [.connecting, .connecting, .connected, .connected]) == [.vpnConnectionAttempt, .vpnConnectionEstablished])
    }

    @Test("Every established or cancelled event follows an attempt")
    func outcomesFollowAttempts() {
        let sequence: [KPIConnectionStatus] = [
            .connecting, .notConnected, .connecting, .connected, .notConnected,
            .connecting, .connected, .reconnecting, .connected, .paused, .connected, .notConnected
        ]
        var openAttempts = 0
        for event in events(for: sequence) {
            switch event {
            case .vpnConnectionAttempt:
                openAttempts = 1
            case .vpnConnectionEstablished, .vpnConnectionCancelled:
                #expect(openAttempts == 1)
                openAttempts = 0
            }
        }
    }

    // MARK: First observation

    @Test("Adopting a tunnel that is already connected reports nothing")
    func adoptConnectedTunnel() {
        #expect(events(for: [.connected, .notConnected], from: nil).isEmpty)
    }

    @Test("Adopting a disconnected tunnel reports nothing")
    func adoptDisconnectedTunnel() {
        #expect(events(for: [.notConnected], from: nil).isEmpty)
    }

    @Test("A connection seen from its start on first observation is reported")
    func firstObservationConnecting() {
        #expect(events(for: [.connecting, .connected], from: nil) == [.vpnConnectionAttempt, .vpnConnectionEstablished])
    }

    // MARK: Status mapping

    @Test("Without a live tunnel the system status decides")
    func systemStatusMapping() {
        #expect(KPIConnectionStatus(system: .connecting, tunnel: nil) == .connecting)
        #expect(KPIConnectionStatus(system: .reasserting, tunnel: nil) == .reconnecting)
        #expect(KPIConnectionStatus(system: .disconnecting, tunnel: .connected) == .notConnected)
        #expect(KPIConnectionStatus(system: .disconnected, tunnel: .connecting) == .notConnected)
        #expect(KPIConnectionStatus(system: .invalid, tunnel: nil) == .notConnected)
    }

    @Test("While the system reports connected the tunnel status decides")
    func tunnelStatusMapping() {
        #expect(KPIConnectionStatus(system: .connected, tunnel: nil) == .connected)
        #expect(KPIConnectionStatus(system: .connected, tunnel: .connected) == .connected)
        #expect(KPIConnectionStatus(system: .connected, tunnel: .connecting) == .connecting)
        #expect(KPIConnectionStatus(system: .connected, tunnel: .reconnecting) == .reconnecting)
        #expect(KPIConnectionStatus(system: .connected, tunnel: .paused) == .paused)
        #expect(KPIConnectionStatus(system: .connected, tunnel: .disconnecting) == .notConnected)
        #expect(KPIConnectionStatus(system: .connected, tunnel: .disconnected) == .notConnected)
    }
}
