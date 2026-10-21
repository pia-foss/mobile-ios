//
//  FavoriteRegionUseCase+Migration.swift
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

import Foundation

extension FavoriteRegionUseCase {
    /// iOS used to store Dedicated IP favorites as `identifier + dipToken`.
    /// Rewrites those entries to the shared `favDIP:<identifier>` format, dropping duplicates.
    public func migrateLegacyDIPFavorites(dipServers: [(identifier: String, dipToken: String)]) throws {
        let current = favoriteIdentifiers
        let legacyKeys = Dictionary(
            dipServers.map { ($0.identifier + $0.dipToken, Self.favDipIdPreffix + $0.identifier) },
            uniquingKeysWith: { first, _ in first }
        )

        var migrated: [String] = []
        for favorite in current {
            let key = legacyKeys[favorite] ?? favorite
            if !migrated.contains(key) {
                migrated.append(key)
            }
        }

        guard migrated != current else { return }
        try keychain.set(favorites: migrated)
        favorites = migrated
    }
}
