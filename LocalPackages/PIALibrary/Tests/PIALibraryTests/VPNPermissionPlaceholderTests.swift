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

// PIATunnelProfile and PIAWGTunnelProfile are only declared for iOS.
#if os(iOS)

    import TunnelKitCore
    import TunnelKitOpenVPN
    import XCTest

    @testable import PIALibrary

    /// Locks the invariant behind the VPN-permission placeholder (KM-17461): a profile
    /// generated from `Server.vpnPermissionPlaceholder` must always carry a non-empty
    /// `serverAddress`, so the OS profile save that grants the one-time VPN permission
    /// cannot fail or persist an empty endpoint when the server list is unavailable.
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

        private func makeConfiguration(customConfiguration: VPNCustomConfiguration? = nil) -> VPNConfiguration {
            VPNConfiguration(
                name: "PIA Test",
                username: "p0000000",
                passwordReference: Data(),
                server: .vpnPermissionPlaceholder,
                isOnDemand: false,
                disconnectsOnSleep: false,
                customConfiguration: customConfiguration,
                leakProtection: false,
                allowLocalDeviceAccess: false
            )
        }

        /// Mirrors the session configuration the app passes in production
        /// (`AppConfiguration.VPN.piaDefaultConfigurationBuilder`), so the test walks the
        /// real `endpointProtocols` / `bestAddressForOVPN(tcp:)` branch and not just the
        /// trivial no-custom-configuration path.
        private func makeOpenVPNConfiguration() -> OpenVPNProvider.Configuration {
            var sessionBuilder = OpenVPN.ConfigurationBuilder()
            sessionBuilder.cipher = .aes128gcm
            sessionBuilder.digest = .sha256
            sessionBuilder.endpointProtocols = [
                EndpointProtocol(.udp, 8080),
                EndpointProtocol(.tcp, 443)
            ]
            sessionBuilder.usesPIAPatches = true
            return OpenVPNProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build()).build()
        }

        func testPlaceholderServerHasNonEmptyHostname() {
            XCTAssertFalse(Server.vpnPermissionPlaceholder.hostname.isEmpty)
            // RFC 6761 reserved TLD: never resolves, never matches PIA-domain checks
            // such as needsMigrationToGEN4().
            XCTAssertTrue(Server.vpnPermissionPlaceholder.hostname.hasSuffix(".invalid"))
            XCTAssertFalse(Server.vpnPermissionPlaceholder.hostname.contains("privateinternetaccess.com"))
        }

        func testWireGuardGeneratedProtocolFallsBackToPlaceholderHostname() throws {
            let profile = PIAWGTunnelProfile(bundleIdentifier: "com.test.wg-tunnel")
            let proto = try profile.generatedProtocol(withConfiguration: makeConfiguration())

            XCTAssertEqual(proto.serverAddress, Server.vpnPermissionPlaceholder.hostname)
        }

        func testOpenVPNGeneratedProtocolFallsBackToPlaceholderHostname() {
            let profile = PIATunnelProfile(bundleIdentifier: "com.test.ovpn-tunnel")
            let configuration = makeConfiguration(customConfiguration: makeOpenVPNConfiguration())
            let proto = profile.generatedProtocol(withConfiguration: configuration)

            XCTAssertEqual(proto.serverAddress, Server.vpnPermissionPlaceholder.hostname)
            XCTAssertNotEqual(proto.serverAddress, "")
        }
    }

#endif
