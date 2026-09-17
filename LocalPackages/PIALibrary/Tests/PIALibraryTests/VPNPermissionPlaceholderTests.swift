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

#if os(iOS)

    import XCTest

    @testable import PIALibrary

    /// Locks what survives of KM-17461's VPN-permission placeholder invariant.
    ///
    /// The original tests asserted that a profile generated from `Server.vpnPermissionPlaceholder`
    /// carries a non-empty `serverAddress`. That was a property of the *legacy* profiles, where
    /// `serverAddress` was the endpoint. `KapePlatformSDKTunnelProfile` deliberately leaves it empty
    /// — the extension resolves endpoints from `PIATunnelSharedState` — so only the placeholder
    /// server's own invariants are still meaningful here.
    class VPNPermissionPlaceholderTests: XCTestCase {

        private var previousLastServerCN: String?

        override func setUp() {
            super.setUp()

            Client.database = Client.Database(group: "group.com.privateinternetaccess")
            Client.providers.accountProvider = MockAccountProvider()
            Client.providers.vpnProvider = MockVPNProvider()

            // generatedProtocol persists lastServerCN as a side effect; keep other
            // tests isolated from the placeholder's empty CN.
            previousLastServerCN = Client.database.plain.lastServerCN
        }

        override func tearDown() {
            Client.database.plain.lastServerCN = previousLastServerCN
            super.tearDown()
        }

        func testPlaceholderServerHasNonEmptyHostname() {
            XCTAssertFalse(Server.vpnPermissionPlaceholder.hostname.isEmpty)
            // RFC 6761 reserved TLD: never resolves, never matches PIA-domain checks
            // such as needsMigrationToGEN4().
            XCTAssertTrue(Server.vpnPermissionPlaceholder.hostname.hasSuffix(".invalid"))
            XCTAssertFalse(Server.vpnPermissionPlaceholder.hostname.contains("privateinternetaccess.com"))
        }

    }

#endif
