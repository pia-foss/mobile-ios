//
//  FavoriteRegionUseCase.swift
//  PIAFavorites
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

public protocol FavoriteRegionUseCaseType: Sendable {
    var favoriteIdentifiers: [String] { get }
    var favoriteIdentifiersPublisher: Published<[String]>.Publisher { get }
    @discardableResult
    func addToFavorites(_ id: String, isDipServer: Bool) throws -> [String]
    @discardableResult
    func removeFromFavorites(_ id: String, isDipServer: Bool) throws -> [String]
    func eraseAllFavorites()
    func getFavoriteDIPServerId() -> String?
    func isFavoriteServerWith(identifier: String, isDipServer: Bool) -> Bool
}

// The Keychain is the source of truth; `favorites` only mirrors it for observers.
public final class FavoriteRegionUseCase: FavoriteRegionUseCaseType, @unchecked Sendable {
    public static let favDipIdPreffix = "favDIP:"

    let keychain: KeychainType

    public init(keychain: KeychainType) {
        self.keychain = keychain
        self.favorites = favoriteIdentifiers
    }

    public var favoriteIdentifiers: [String] {
        if let favorites = try? keychain.getFavorites() {
            return favorites
        }

        return []
    }

    @Published internal var favorites: [String] = []

    public var favoriteIdentifiersPublisher: Published<[String]>.Publisher {
        $favorites
    }

    @discardableResult
    public func addToFavorites(_ id: String, isDipServer: Bool) throws -> [String] {
        var newFavorites = favoriteIdentifiers
        let newFavoriteId = isDipServer ? calculateServerIdForDipServer(id) : id
        newFavorites.append(newFavoriteId)
        try keychain.set(favorites: newFavorites)
        favorites = newFavorites
        return newFavorites
    }

    @discardableResult
    public func removeFromFavorites(_ id: String, isDipServer: Bool) throws -> [String] {
        let storedFavoriteId = isDipServer ? calculateServerIdForDipServer(id) : id
        let newFavorites = favoriteIdentifiers.filter { storedFavoriteId != $0 }
        try keychain.set(favorites: newFavorites)
        favorites = newFavorites
        return newFavorites
    }

    public func eraseAllFavorites() {
        do {
            try keychain.eraseAllFavorites()
            self.favorites = []
        } catch {
            // No op
        }

    }

    private func calculateServerIdForDipServer(_ id: String) -> String {
        return Self.favoriteKey(identifier: id, isDipServer: true)
    }

    /// The identifier stored in the Keychain for a server.
    public static func favoriteKey(identifier: String, isDipServer: Bool) -> String {
        isDipServer ? "\(favDipIdPreffix)\(identifier)" : identifier
    }

    public func getFavoriteDIPServerId() -> String? {
        guard let storedFavIdWithPreffix = favoriteIdentifiers.filter({ $0.hasPrefix(Self.favDipIdPreffix) }).first else {
            return nil
        }

        let dipServerIdWithoutPreffix = String(storedFavIdWithPreffix.dropFirst(Self.favDipIdPreffix.count))

        return dipServerIdWithoutPreffix
    }

    public func isFavoriteServerWith(identifier: String, isDipServer: Bool) -> Bool {
        if isDipServer {
            guard let savedFavoriteDipServerId = getFavoriteDIPServerId() else { return false }
            return savedFavoriteDipServerId == identifier
        } else {
            return favoriteIdentifiers.contains(identifier)
        }

    }
}
