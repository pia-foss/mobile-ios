//
//  KeychainType.swift
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
import PIALibrary

public protocol KeychainType: Sendable {
    func getFavorites() throws -> [String]
    func set(favorites: [String]) throws
    func eraseAllFavorites() throws

    // Add methods from `Keychain` class as needed
}

extension Keychain: KeychainType {
    public func eraseAllFavorites() throws {
        try set(favorites: [])
    }
}
