//
//  DefaultServerProviderTargetServerTests.swift
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

class DefaultServerProviderTargetServerTests: XCTestCase {

    private var originalServerProvider: ServerProvider!
    private var serverProvider: DefaultServerProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        originalServerProvider = Client.providers.serverProvider
        Client.database = Client.Database(group: "group.com.privateinternetaccess").truncate()
        serverProvider = try XCTUnwrap(ServerProviderFactory.makeDefaultServerProvider() as? DefaultServerProvider)
        Client.providers.serverProvider = serverProvider
    }

    override func tearDown() {
        Client.configuration.bundledServersJSON = nil
        Client.database.truncate()
        Client.providers.serverProvider = originalServerProvider
        serverProvider = nil
        super.tearDown()
    }

    func test_targetServer_reloadsBundledServers_whenCacheIsEmpty() throws {
        // GIVEN an empty cache (no preferred/best/last-connected server either) and a
        // bundled servers JSON available
        Client.configuration.bundledServersJSON = try minimalBundleJSON(regionIdentifiers: ["region-a", "region-b"])
        XCTAssertTrue(serverProvider.currentServers.isEmpty)

        // WHEN resolving targetServer, which would otherwise throw noServersAvailable
        let server = try serverProvider.targetServer

        // THEN it self-heals from the bundle, returning one of the reloaded servers
        let reloaded = serverProvider.currentServers
        XCTAssertFalse(reloaded.isEmpty)
        XCTAssertTrue(reloaded.contains { $0.identifier == server.identifier })
    }

    func test_targetServer_doesNotReload_whenCacheIsAlreadyPopulated() throws {
        // GIVEN a cache that's already populated, and a different bundle available
        let existing = Server(
            serial: "",
            name: "Existing",
            country: "us",
            hostname: "existing.invalid",
            pingAddress: nil,
            regionIdentifier: "existing"
        )
        serverProvider.currentServers = [existing]
        Client.configuration.bundledServersJSON = try minimalBundleJSON(regionIdentifiers: ["from-bundle"])

        // WHEN resolving targetServer with nothing else to resolve against
        let resolved = try serverProvider.targetServer

        // THEN the already-cached server is left untouched — the bundle is never reloaded
        XCTAssertEqual(resolved.identifier, existing.identifier)
        XCTAssertEqual(serverProvider.currentServers.map(\.identifier), [existing.identifier])
    }

    func test_targetServer_reResolvesPreferredServer_afterReload() throws {
        // GIVEN a bundle with more than one server, and a persisted preferred server
        // that isn't first in the bundle
        let bundleJSON = try minimalBundleJSON(regionIdentifiers: ["first", "preferred"])
        Client.configuration.bundledServersJSON = bundleJSON
        serverProvider.loadLocalJSON(fromJSON: bundleJSON)
        let allServers = serverProvider.currentServers
        let preferred = try XCTUnwrap(allServers.first { $0.identifier == "preferred" })
        Client.database.plain.preferredServer = preferred

        // AND the cache is empty again (e.g. right after logout, before the daemon re-downloads)
        serverProvider.currentServers = []
        XCTAssertTrue(serverProvider.currentServers.isEmpty)

        // WHEN resolving targetServer, which reloads the bundle
        let resolved = try serverProvider.targetServer

        // THEN it re-resolves the persisted preferred server instead of returning an
        // arbitrary server from the freshly-reloaded cache
        XCTAssertEqual(resolved.identifier, preferred.identifier)
    }

    func test_targetServer_reResolvesLastConnectedRegion_afterReload() throws {
        // GIVEN a bundle with more than one server, and a persisted "last connected" region
        // that isn't the first server in the bundle
        let bundleJSON = try minimalBundleJSON(regionIdentifiers: ["first", "last-connected"])
        Client.configuration.bundledServersJSON = bundleJSON
        serverProvider.loadLocalJSON(fromJSON: bundleJSON)
        let allServers = serverProvider.currentServers
        let lastConnected = try XCTUnwrap(allServers.first { $0.identifier == "last-connected" })
        Client.database.plain.lastConnectedRegion = lastConnected

        // AND the cache is empty again (e.g. right after logout, before the daemon re-downloads)
        serverProvider.currentServers = []
        XCTAssertTrue(serverProvider.currentServers.isEmpty)

        // WHEN resolving targetServer, which reloads the bundle
        let resolved = try serverProvider.targetServer

        // THEN it re-resolves the persisted last-connected region instead of returning an
        // arbitrary server from the freshly-reloaded cache
        XCTAssertEqual(resolved.identifier, lastConnected.identifier)
    }

    func test_targetServer_stillThrows_whenNoBundledServersJSONAvailable() {
        // GIVEN an empty cache and no bundled servers JSON configured
        Client.configuration.bundledServersJSON = nil
        XCTAssertTrue(serverProvider.currentServers.isEmpty)

        // WHEN/THEN resolving targetServer still throws noServersAvailable
        XCTAssertThrowsError(try serverProvider.targetServer) { error in
            XCTAssertEqual(error as? ClientError, ClientError.noServersAvailable)
        }
    }

    func test_targetServer_fallsBackToArbitraryRegion_whenPreferredServerIsDIP_afterReload() throws {
        // GIVEN a persisted preferred server that's a DIP (dedicated IP) server — matched by
        // both identifier and dipToken — which never appears in the bundled servers JSON
        let dipServer = Server(
            serial: "",
            name: "My Dedicated IP",
            country: "us",
            hostname: "dip-server.invalid",
            pingAddress: nil,
            dipToken: "dip-token-123",
            regionIdentifier: "dip-server"
        )
        Client.database.plain.preferredServer = dipServer

        // AND the cache is empty again (e.g. right after logout, before the daemon re-downloads)
        serverProvider.currentServers = []
        Client.configuration.bundledServersJSON = try minimalBundleJSON(regionIdentifiers: ["region-a", "region-b"])
        XCTAssertTrue(serverProvider.currentServers.isEmpty)

        // WHEN resolving targetServer, which reloads the bundle
        let resolved = try serverProvider.targetServer

        // THEN the DIP preference can't be re-resolved — bundled servers never carry a
        // dipToken — so it silently falls through to an arbitrary regular region instead
        // of the user's dedicated IP. This pins current behavior; it isn't necessarily the
        // desired one.
        XCTAssertNotEqual(resolved.identifier, dipServer.identifier)
        XCTAssertEqual(resolved.identifier, serverProvider.currentServers.first?.identifier)
    }

    /// Builds a minimal `ServersBundle`-shaped JSON with no server addresses, so loading it
    /// never triggers `ServersPinger`'s real network ping sweep (`Server.addresses()` is empty
    /// when no protocol addresses are decoded).
    private func minimalBundleJSON(regionIdentifiers: [String]) throws -> Data {
        let regions = regionIdentifiers.map { identifier in
            [
                "id": identifier,
                "name": identifier,
                "country": "us",
                "dns": "\(identifier).invalid"
            ]
        }
        let payload: [String: Any] = ["groups": [String: Any](), "regions": regions]
        return try JSONSerialization.data(withJSONObject: payload)
    }
}
