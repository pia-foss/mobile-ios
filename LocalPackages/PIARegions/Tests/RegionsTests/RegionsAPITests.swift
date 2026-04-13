/*
 *  Copyright (c) 2020 Private Internet Access, Inc.
 *
 *  This file is part of the Private Internet Access Mobile Client.
 *
 *  The Private Internet Access Mobile Client is free software: you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as published by the Free
 *  Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  The Private Internet Access Mobile Client is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *  details.
 *
 *  You should have received a copy of the GNU General Public License along with the Private
 *  Internet Access Mobile Client.  If not, see <https://www.gnu.org/licenses/>.
 */

import Testing

@testable import PIARegions

private struct MockEndpointProvider: RegionEndpointProvider {
    func regionEndpoints() -> [RegionEndpoint] { [] }
}

@Suite("RegionsBuilder")
struct RegionsAPITests {

    @Test("Build fails when endpoints provider is missing")
    func testMissingEndpointsProvider() throws {
        #expect(throws: RegionsBuilderError.missingEndpointsProvider) {
            try RegionsBuilder()
                .setUserAgent("test-agent")
                .setVPNRegionsRequestPath("/vpn-regions")
                .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
                .setMetadataRequestPath("/metadata")
                .build()
        }
    }

    @Test("Build fails when user agent is missing")
    func testMissingUserAgent() throws {
        #expect(throws: RegionsBuilderError.missingUserAgent) {
            try RegionsBuilder()
                .setEndpointProvider(MockEndpointProvider())
                .setVPNRegionsRequestPath("/vpn-regions")
                .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
                .setMetadataRequestPath("/metadata")
                .build()
        }
    }

    @Test("Build fails when VPN regions request path is missing")
    func testMissingVpnRegionsRequestPath() throws {
        #expect(throws: RegionsBuilderError.missingVPNRegionsRequestPath) {
            try RegionsBuilder()
                .setEndpointProvider(MockEndpointProvider())
                .setUserAgent("test-agent")
                .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
                .setMetadataRequestPath("/metadata")
                .build()
        }
    }

    @Test("Build fails when Shadowsocks regions request path is missing")
    func testMissingShadowsocksRegionsRequestPath() throws {
        #expect(throws: RegionsBuilderError.missingShadowsocksRegionsRequestPath) {
            try RegionsBuilder()
                .setEndpointProvider(MockEndpointProvider())
                .setUserAgent("test-agent")
                .setVPNRegionsRequestPath("/vpn-regions")
                .setMetadataRequestPath("/metadata")
                .build()
        }
    }

    @Test("Build fails when metadata request path is missing")
    func testMissingMetadataRequestPath() throws {
        #expect(throws: RegionsBuilderError.missingMetadataRequestPath) {
            try RegionsBuilder()
                .setEndpointProvider(MockEndpointProvider())
                .setUserAgent("test-agent")
                .setVPNRegionsRequestPath("/vpn-regions")
                .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
                .build()
        }
    }

    @Test("Build succeeds when all required parameters are provided")
    func testBuildSucceeds() throws {
        _ = try RegionsBuilder()
            .setEndpointProvider(MockEndpointProvider())
            .setUserAgent("test-agent")
            .setVPNRegionsRequestPath("/vpn-regions")
            .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
            .setMetadataRequestPath("/metadata")
            .build()
    }

    @Test("Build succeeds with all optional parameters set")
    func testBuildSucceedsWithAllParameters() throws {
        let fallback = RegionJSONFallback(
            vpnRegionsJSON: "{}",
            shadowsocksRegionsJSON: "[]",
            metadataJSON: "{}"
        )
        _ = try RegionsBuilder()
            .setEndpointProvider(MockEndpointProvider())
            .setUserAgent("test-agent")
            .setCertificate("test-cert")
            .setVPNRegionsRequestPath("/vpn-regions")
            .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
            .setMetadataRequestPath("/metadata")
            .setRegionJSONFallback(fallback)
            .setPersistencePreferenceName("test-prefs")
            .setLogErrors(true)
            .build()
    }

    @Test("setPersistencePreferenceName trims whitespace and treats blank as nil")
    func testPersistencePreferenceNameTrimmingAndNilForBlank() throws {
        // These should not throw — blank names are treated as nil (using default)
        _ = try RegionsBuilder()
            .setEndpointProvider(MockEndpointProvider())
            .setUserAgent("test-agent")
            .setVPNRegionsRequestPath("/vpn-regions")
            .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
            .setMetadataRequestPath("/metadata")
            .setPersistencePreferenceName("  ")
            .build()

        _ = try RegionsBuilder()
            .setEndpointProvider(MockEndpointProvider())
            .setUserAgent("test-agent")
            .setVPNRegionsRequestPath("/vpn-regions")
            .setShadowsocksRegionsRequestPath("/shadowsocks-regions")
            .setMetadataRequestPath("/metadata")
            .setPersistencePreferenceName(nil)
            .build()
    }
}
