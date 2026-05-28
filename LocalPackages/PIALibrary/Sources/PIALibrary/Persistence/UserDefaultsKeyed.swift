//
//  UserDefaultsKeyed.swift
//  PIALibrary
//
//  Created by Mario on 02/06/2026.
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

final class UserDefaultsKeyed<Key> where Key: RawRepresentable, Key.RawValue == String {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func array(forKey key: Key) -> [Any]? {
        return defaults.array(forKey: key.rawValue)
    }

    func bool(forKey key: Key) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }

    func data(forKey key: Key) -> Data? {
        return defaults.data(forKey: key.rawValue)
    }

    func dictionary(forKey key: Key) -> [String: Any]? {
        return defaults.dictionary(forKey: key.rawValue)
    }

    func double(forKey key: Key) -> Double {
        return defaults.double(forKey: key.rawValue)
    }

    func object(forKey key: Key) -> Any? {
        return defaults.object(forKey: key.rawValue)
    }

    func removeObject(forKey key: Key) {
        return defaults.removeObject(forKey: key.rawValue)
    }

    func removePersistentDomain(forName domainName: String) {
        return defaults.removePersistentDomain(forName: domainName)
    }

    func set(_ value: Any?, forKey key: Key) {
        return defaults.set(value, forKey: key.rawValue)
    }

    func string(forKey key: Key) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    @discardableResult
    func synchronize() -> Bool {
        return defaults.synchronize()
    }
}
