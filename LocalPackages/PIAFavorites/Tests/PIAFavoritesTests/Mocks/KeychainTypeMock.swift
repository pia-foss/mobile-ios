//
//  KeychainTypeMock.swift
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

import Foundation
import PIAFavorites

final class KeychainTypeMock: KeychainType, @unchecked Sendable {

    var eraseAllFavoritesCalledAttempt = 0
    var eraseAllFavoritesResultError: Error?
    func eraseAllFavorites() throws {
        eraseAllFavoritesCalledAttempt += 1
        if let error = eraseAllFavoritesResultError {
            throw error
        }
        getFavoritesResultSuccess = []
    }

    var getFavoritesResultError: Error?
    var getFavoritesResultSuccess: [String] = []
    func getFavorites() throws -> [String] {
        if let error = getFavoritesResultError {
            throw error
        }
        return getFavoritesResultSuccess
    }

    var setFavoritesCalledAttempt = 0
    var setFavoritesCalledWithArgument: [String]?
    var setFavoritesResultError: Error?
    func set(favorites: [String]) throws {
        setFavoritesCalledAttempt += 1
        setFavoritesCalledWithArgument = favorites
        if let error = setFavoritesResultError {
            throw error
        }
        getFavoritesResultSuccess = favorites
    }
}
