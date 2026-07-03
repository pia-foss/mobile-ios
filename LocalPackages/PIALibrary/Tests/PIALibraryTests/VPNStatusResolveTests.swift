//
//  VPNStatusResolveTests.swift
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

import NetworkExtension
import Testing

@testable import PIALibrary

@Suite("VPNStatus.resolve(system:tunnel:)")
struct VPNStatusResolveTests {

    // MARK: Legacy path (tunnel == nil) is a pure NEVPNStatus mapping

    @Test("With no tunnel status, resolve is a pure NEVPNStatus mapping")
    func legacyMapping() {
        #expect(VPNStatus.resolve(system: .connected, tunnel: nil) == .connected)
        #expect(VPNStatus.resolve(system: .connecting, tunnel: nil) == .connecting)
        #expect(VPNStatus.resolve(system: .reasserting, tunnel: nil) == .connecting)
        #expect(VPNStatus.resolve(system: .disconnecting, tunnel: nil) == .disconnecting)
        #expect(VPNStatus.resolve(system: .disconnected, tunnel: nil) == .disconnected)
        #expect(VPNStatus.resolve(system: .invalid, tunnel: nil) == .disconnected)
    }

    // MARK: Tunnel nuance only applies while the OS says connected

    @Test("A connected tunnel that is re-establishing surfaces as .connecting")
    func reconnectOverlayWhileConnected() {
        #expect(VPNStatus.resolve(system: .connected, tunnel: .connecting) == .connecting)
        #expect(VPNStatus.resolve(system: .connected, tunnel: .reconnecting) == .connecting)
        #expect(VPNStatus.resolve(system: .connected, tunnel: .paused) == .connecting)
    }

    @Test("A settled connected tunnel is .connected")
    func connectedOverlay() {
        #expect(VPNStatus.resolve(system: .connected, tunnel: .connected) == .connected)
    }

    @Test("Tunnel teardown does not override the OS while it still reports connected")
    func teardownDoesNotOverrideConnected() {
        // NEVPNStatus owns teardown; a transient tunnel disconnecting/disconnected while the OS still
        // says connected (e.g. mid-reconnect between endpoints) must not flash the UI to disconnected.
        #expect(VPNStatus.resolve(system: .connected, tunnel: .disconnecting) == .connected)
        #expect(VPNStatus.resolve(system: .connected, tunnel: .disconnected) == .connected)
    }

    @Test("The OS baseline wins outside .connected, regardless of tunnel status")
    func osBaselineWins() {
        #expect(VPNStatus.resolve(system: .disconnected, tunnel: .connected) == .disconnected)
        #expect(VPNStatus.resolve(system: .disconnecting, tunnel: .connected) == .disconnecting)
        #expect(VPNStatus.resolve(system: .connecting, tunnel: .connected) == .connecting)
    }
}
