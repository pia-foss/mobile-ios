//
//  FavoriteRegionUseCaseTests.swift
//  PIAFavoritesTests
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

import Combine
import Foundation
import PIALibrary
import Testing

@testable import PIAFavorites

@Suite("FavoriteRegionUseCase")
struct FavoriteRegionUseCaseTests {
    private let keychain = KeychainTypeMock()

    private func makeSUT(stored: [String]) -> FavoriteRegionUseCase {
        keychain.getFavoritesResultSuccess = stored
        return FavoriteRegionUseCase(keychain: keychain)
    }

    @Test("Adding a regular server appends it and publishes the new list")
    func addRegular() throws {
        // GIVEN one stored favorite
        let sut = makeSUT(stored: ["server-id-one"])
        var published: [String] = []
        let cancellable = sut.favoriteIdentifiersPublisher.sink { published = $0 }
        defer { cancellable.cancel() }
        #expect(published == ["server-id-one"])

        // WHEN adding a regular server
        let newFavorites = try sut.addToFavorites("server-id-two", isDipServer: false)

        // THEN it is appended and published
        #expect(newFavorites == ["server-id-one", "server-id-two"])
        #expect(published == ["server-id-one", "server-id-two"])
    }

    @Test("Adding or removing throws when the Keychain fails", arguments: [false, true])
    func keychainFailure(isDipServer: Bool) {
        // GIVEN a Keychain that fails to save
        let sut = makeSUT(stored: ["server-id-one"])
        keychain.setFavoritesResultError = KeychainError.add

        // THEN both operations throw
        #expect(throws: KeychainError.self) { try sut.addToFavorites("server-id-two", isDipServer: isDipServer) }
        #expect(throws: KeychainError.self) { try sut.removeFromFavorites("server-id-one", isDipServer: isDipServer) }
    }

    @Test("Removing a regular server removes it and publishes the new list")
    func removeRegular() throws {
        // GIVEN one stored favorite
        let sut = makeSUT(stored: ["server-id-one"])
        var published: [String] = ["sentinel"]
        let cancellable = sut.favoriteIdentifiersPublisher.sink { published = $0 }
        defer { cancellable.cancel() }

        // WHEN removing it
        let newFavorites = try sut.removeFromFavorites("server-id-one", isDipServer: false)

        // THEN the list is empty
        #expect(newFavorites.isEmpty)
        #expect(published.isEmpty)
    }

    @Test("Dedicated IP servers are stored with the favDIP prefix")
    func addDip() throws {
        // GIVEN one stored favorite
        let sut = makeSUT(stored: ["server-id-one"])

        // WHEN adding a DIP server, even with an identifier that is already a favorite
        let newFavorites = try sut.addToFavorites("server-id-one", isDipServer: true)

        // THEN the prefixed id is appended next to the regular one
        #expect(newFavorites == ["server-id-one", "favDIP:server-id-one"])
    }

    @Test("Removing a DIP server only removes the prefixed entry")
    func removeDip() throws {
        // GIVEN a regular favorite and a DIP favorite
        let sut = makeSUT(stored: ["server-id-one", "favDIP:server-id-two"])

        // WHEN removing "server-id-one" as a DIP server
        let unchanged = try sut.removeFromFavorites("server-id-one", isDipServer: true)
        // THEN nothing changes
        #expect(unchanged == ["server-id-one", "favDIP:server-id-two"])

        // WHEN removing "server-id-two" as a DIP server
        let newFavorites = try sut.removeFromFavorites("server-id-two", isDipServer: true)
        // THEN only the regular favorite remains
        #expect(newFavorites == ["server-id-one"])
    }

    @Test("The favorite DIP server id is returned without its prefix")
    func favoriteDIPServerId() {
        #expect(makeSUT(stored: ["server-id-one", "favDIP:server-id-two"]).getFavoriteDIPServerId() == "server-id-two")
        #expect(makeSUT(stored: ["server-id-one", "server-id-two"]).getFavoriteDIPServerId() == nil)
    }

    @Test("isFavoriteServerWith tells regular and DIP favorites apart")
    func isFavorite() {
        // GIVEN only regular favorites
        let regular = makeSUT(stored: ["server-id-one", "server-id-two"])
        #expect(regular.isFavoriteServerWith(identifier: "server-id-two", isDipServer: false))
        #expect(!regular.isFavoriteServerWith(identifier: "server-id-two", isDipServer: true))

        // GIVEN a DIP favorite
        let dip = makeSUT(stored: ["server-id-one", "favDIP:server-id-two"])
        #expect(!dip.isFavoriteServerWith(identifier: "server-id-two", isDipServer: false))
        #expect(dip.isFavoriteServerWith(identifier: "server-id-two", isDipServer: true))
    }

    @Test("Erasing all favorites empties the list")
    func eraseAll() {
        // GIVEN two favorites
        let sut = makeSUT(stored: ["server-id-one", "server-id-two"])
        #expect(sut.favorites.count == 2)

        // WHEN erasing all favorites
        sut.eraseAllFavorites()

        // THEN the list is empty
        #expect(sut.favorites.isEmpty)
    }

    @Test("Legacy iOS DIP favorites are rewritten with the favDIP prefix")
    func migrateLegacy() throws {
        // GIVEN a regular favorite and a legacy DIP favorite
        let sut = makeSUT(stored: ["server-id-one", "server-id-twoTOKEN"])

        // WHEN migrating
        try sut.migrateLegacyDIPFavorites(dipServers: [(identifier: "server-id-two", dipToken: "TOKEN")])

        // THEN the DIP entry uses the shared format
        #expect(keychain.getFavoritesResultSuccess == ["server-id-one", "favDIP:server-id-two"])
        #expect(sut.isFavoriteServerWith(identifier: "server-id-two", isDipServer: true))
    }

    @Test("Migrating twice or without legacy entries does not write")
    func migrateIdempotent() throws {
        // GIVEN favorites already in the shared format, plus an unrelated entry
        let sut = makeSUT(stored: ["server-id-one", "favDIP:server-id-two", "unknownTOKEN"])

        // WHEN migrating with a different token
        try sut.migrateLegacyDIPFavorites(dipServers: [(identifier: "server-id-two", dipToken: "TOKEN")])

        // THEN nothing is written
        #expect(keychain.setFavoritesCalledAttempt == 0)
        #expect(keychain.getFavoritesResultSuccess == ["server-id-one", "favDIP:server-id-two", "unknownTOKEN"])
    }

    @Test("Migrating drops a legacy entry that duplicates an already migrated one")
    func migrateDuplicates() throws {
        // GIVEN both formats for the same DIP server
        let sut = makeSUT(stored: ["favDIP:server-id-two", "server-id-twoTOKEN"])

        // WHEN migrating
        try sut.migrateLegacyDIPFavorites(dipServers: [(identifier: "server-id-two", dipToken: "TOKEN")])

        // THEN only one entry remains
        #expect(keychain.getFavoritesResultSuccess == ["favDIP:server-id-two"])
    }
}
