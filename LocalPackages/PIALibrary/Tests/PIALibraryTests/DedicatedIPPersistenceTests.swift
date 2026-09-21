//
//  DedicatedIPPersistenceTests.swift
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

/// Covers what it takes for a Dedicated IP region to survive a relaunch.
final class DedicatedIPPersistenceTests: XCTestCase {

    private var originalServerProvider: ServerProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        originalServerProvider = Client.providers.serverProvider
        Client.database = Client.Database(group: "group.com.privateinternetaccess").truncate()
    }

    override func tearDown() {
        Client.database.truncate()
        Client.providers.serverProvider = originalServerProvider
        super.tearDown()
    }

    // MARK: - Cache round trip

    func testDedicatedIPCredentialsSurviveTheCacheRoundTrip() throws {
        let server = makeDedicatedIPServer()

        let decoded = try JSONDecoder().decode(Server.self, from: JSONEncoder().encode(server))

        // `dipUsername` keys the keychain password and cannot be recomputed once dropped.
        XCTAssertEqual(decoded.dipToken, server.dipToken)
        XCTAssertEqual(decoded.dipUsername, server.dipUsername)
        XCTAssertEqual(decoded.dipStatus, server.dipStatus)
        XCTAssertEqual(decoded.dipExpire, server.dipExpire)
    }

    func testDedicatedIPCredentialsSurviveTheCachedServersStore() throws {
        let server = makeDedicatedIPServer()

        Client.database.plain.cachedServers = [server]
        // Drop the in-memory copy so the read comes back through the persisted JSON.
        Client.database = Client.Database(group: "group.com.privateinternetaccess")

        let cached = try XCTUnwrap(Client.database.plain.cachedServers.first)
        XCTAssertEqual(cached.dipUsername, server.dipUsername)
        XCTAssertEqual(cached.dipStatus, server.dipStatus)
        XCTAssertEqual(cached.dipExpire, server.dipExpire)
    }

    // MARK: - Selection

    func testPreferredServerSurvivesACommitTakenWhileTheServerIsMissing() {
        let dipServer = makeDedicatedIPServer()
        Client.database.plain.cachedServers = [dipServer]
        Client.database.plain.preferredServer = dipServer

        // A refresh without the DIP region: the getter can no longer resolve it.
        Client.database.plain.cachedServers = [makeRegularServer()]
        XCTAssertNil(Client.database.plain.preferredServer)

        // Bootstrap snapshots and commits the preferences on every launch.
        Client.preferences.editable().commit()

        Client.database.plain.cachedServers = [dipServer]
        XCTAssertEqual(Client.database.plain.preferredServer?.identifier, dipServer.identifier)
        XCTAssertEqual(Client.database.plain.preferredServer?.dipToken, dipServer.dipToken)
    }

    func testLastConnectedRegionSurvivesACommitTakenWhileTheServerIsMissing() {
        let dipServer = makeDedicatedIPServer()
        Client.database.plain.cachedServers = [dipServer]
        Client.database.plain.lastConnectedRegion = dipServer

        Client.database.plain.cachedServers = [makeRegularServer()]
        Client.preferences.editable().commit()

        Client.database.plain.cachedServers = [dipServer]
        XCTAssertEqual(Client.database.plain.lastConnectedRegion?.identifier, dipServer.identifier)
    }

    func testPreferredServerIsStillClearedWhenTheSelectionResolves() {
        let server = makeRegularServer()
        Client.database.plain.cachedServers = [server]
        Client.database.plain.preferredServer = server
        XCTAssertNotNil(Client.database.plain.preferredServer)

        // Choosing automatic while the server list is healthy must still clear the selection.
        Client.database.plain.preferredServer = nil

        XCTAssertNil(Client.database.plain.preferredServer)
        Client.database.plain.cachedServers = [server]
        XCTAssertNil(Client.database.plain.preferredServer)
    }

    // MARK: - Refresh

    func testDownloadKeepsCachedDedicatedIPServersWhenNoTokensAreReadable() throws {
        let dipServer = makeDedicatedIPServer()
        let webServices = MockWebServices()
        webServices.serversBundle = { ServersBundle(servers: [self.makeRegularServer()], configuration: nil) }

        let provider = DefaultServerProvider(
            webServices: webServices,
            renewDedicatedIP: MockRenewDedicatedIPUseCase(),
            getDedicatedIPs: MockGetDedicatedIPsUseCase(),
            dedicatedIPServerMapper: MockDedicatedIPServerMapper()
        )
        Client.providers.serverProvider = provider
        provider.currentServers = [dipServer]

        // No readable DIP tokens, as when the keychain is locked.
        XCTAssertTrue(Client.database.secure.dipTokens()?.isEmpty ?? true)

        let downloaded = expectation(description: "download")
        provider.download { _, _ in downloaded.fulfill() }
        wait(for: [downloaded], timeout: 5.0)

        XCTAssertTrue(provider.currentServers.contains { $0.dipToken == dipServer.dipToken })
        XCTAssertTrue(provider.currentServers.contains { $0.identifier == "regular-server" })
    }

    // MARK: - Helpers

    private func makeDedicatedIPServer() -> Server {
        return Server(
            serial: "serial",
            name: "My Dedicated IP",
            country: "de",
            hostname: "dip-server.invalid",
            pingAddress: nil,
            dipExpire: Date(timeIntervalSince1970: 2_000_000_000),
            dipToken: "dip-token-123",
            dipStatus: .active,
            dipUsername: "dedicated_ip_dip-token-123_ab12cd34",
            regionIdentifier: "dip-server"
        )
    }

    private func makeRegularServer() -> Server {
        return Server(
            serial: "",
            name: "Regular",
            country: "de",
            hostname: "regular-server.invalid",
            pingAddress: nil,
            regionIdentifier: "regular"
        )
    }
}
