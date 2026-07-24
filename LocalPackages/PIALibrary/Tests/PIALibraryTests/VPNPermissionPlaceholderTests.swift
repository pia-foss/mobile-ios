//
//  VPNPermissionPlaceholderTests.swift
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

/// Locks the invariant behind the VPN-permission placeholder (KM-17461): a profile
/// generated from `Server.vpnPermissionPlaceholder` must always carry a non-empty
/// `serverAddress`, so the OS profile save that grants the one-time VPN permission
/// cannot fail or persist an empty endpoint when the server list is unavailable.
class VPNPermissionPlaceholderTests: XCTestCase {

    override func setUp() {
        super.setUp()

        Client.database = Client.Database(group: "group.com.privateinternetaccess")
        Client.providers.accountProvider = MockAccountProvider()
        Client.providers.vpnProvider = MockVPNProvider()
    }

    private func makeConfiguration() -> VPNConfiguration {
        VPNConfiguration(
            name: "PIA Test",
            username: "p0000000",
            passwordReference: Data(),
            server: .vpnPermissionPlaceholder,
            isOnDemand: false,
            disconnectsOnSleep: false,
            customConfiguration: nil,
            leakProtection: false,
            allowLocalDeviceAccess: false
        )
    }

    func testPlaceholderServerHasNonEmptyHostname() {
        XCTAssertFalse(Server.vpnPermissionPlaceholder.hostname.isEmpty)
        // The placeholder carries no protocol addresses; profiles must fall back to hostname.
        XCTAssertNil(Server.vpnPermissionPlaceholder.bestAddress())
    }

    func testWireGuardGeneratedProtocolFallsBackToPlaceholderHostname() throws {
        let profile = PIAWGTunnelProfile(bundleIdentifier: "com.test.wg-tunnel")
        let proto = try profile.generatedProtocol(withConfiguration: makeConfiguration())

        XCTAssertEqual(proto.serverAddress, Server.vpnPermissionPlaceholder.hostname)
    }

    func testOpenVPNGeneratedProtocolFallsBackToPlaceholderHostname() {
        let profile = PIATunnelProfile(bundleIdentifier: "com.test.ovpn-tunnel")
        let proto = profile.generatedProtocol(withConfiguration: makeConfiguration())

        XCTAssertEqual(proto.serverAddress, Server.vpnPermissionPlaceholder.hostname)
        XCTAssertNotEqual(proto.serverAddress, "")
    }
}
