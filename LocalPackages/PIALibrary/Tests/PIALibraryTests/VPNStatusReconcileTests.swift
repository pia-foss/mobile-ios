//
//  VPNStatusReconcileTests.swift
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
import XCTest

@testable import PIALibrary

class VPNStatusReconcileTests: XCTestCase {

    /// Regression test: the app used to report `.connected` whenever *any* VPN tunnel existed on
    /// the device. Once PIA's own configuration is loaded and says it is not connected, the
    /// optimistic launch status must be corrected.
    func testStaleConnectedStatusIsCorrectedFromOwnConfiguration() {
        XCTAssertEqual(VPNStatus.reconciled(current: .connected, nativeStatus: .disconnected), .disconnected)
        XCTAssertEqual(VPNStatus.reconciled(current: .connected, nativeStatus: .invalid), .disconnected)
        XCTAssertEqual(VPNStatus.reconciled(current: .connected, nativeStatus: .connecting), .connecting)
        XCTAssertEqual(VPNStatus.reconciled(current: .connected, nativeStatus: .reasserting), .connecting)
        XCTAssertEqual(VPNStatus.reconciled(current: .connected, nativeStatus: .disconnecting), .disconnecting)
    }

    /// A tunnel brought up by on-demand rules while the app was not running is genuine,
    /// PIA-specific evidence and must be adopted whatever the restored status was.
    func testGenuineOwnConnectionIsAdopted() {
        XCTAssertEqual(VPNStatus.reconciled(current: .disconnected, nativeStatus: .connected), .connected)
        XCTAssertEqual(VPNStatus.reconciled(current: .unknown, nativeStatus: .connected), .connected)
        XCTAssertEqual(VPNStatus.reconciled(current: .connecting, nativeStatus: .connected), .connected)
    }

    /// No redundant write when the restored status already matches our own configuration —
    /// `transient.vpnStatus`'s `didSet` posts a notification to the whole app.
    func testMatchingConnectedStatusIsLeftAlone() {
        XCTAssertNil(VPNStatus.reconciled(current: .connected, nativeStatus: .connected))
    }

    /// This late callback must never clobber a status that came from a real
    /// `NEVPNStatusDidChange` for our own manager, or from the user tapping Connect while the
    /// configuration was still loading.
    func testInFlightStatusesAreNeverClobbered() {
        let nonConnectedNativeStatuses: [NEVPNStatus] = [.disconnected, .invalid, .connecting, .reasserting, .disconnecting]

        for nativeStatus in nonConnectedNativeStatuses {
            XCTAssertNil(VPNStatus.reconciled(current: .connecting, nativeStatus: nativeStatus))
            XCTAssertNil(VPNStatus.reconciled(current: .disconnecting, nativeStatus: nativeStatus))
            XCTAssertNil(VPNStatus.reconciled(current: .disconnected, nativeStatus: nativeStatus))
            XCTAssertNil(VPNStatus.reconciled(current: .unknown, nativeStatus: nativeStatus))
        }
    }

    func testNativeStatusMapping() {
        XCTAssertEqual(VPNStatus.from(nativeStatus: .connected), .connected)
        XCTAssertEqual(VPNStatus.from(nativeStatus: .connecting), .connecting)
        XCTAssertEqual(VPNStatus.from(nativeStatus: .reasserting), .connecting)
        XCTAssertEqual(VPNStatus.from(nativeStatus: .disconnecting), .disconnecting)
        XCTAssertEqual(VPNStatus.from(nativeStatus: .disconnected), .disconnected)
        XCTAssertEqual(VPNStatus.from(nativeStatus: .invalid), .disconnected)
    }
}
