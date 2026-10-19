//
//  SearchedRegionsAvailability.swift
//  PIARegionListDomain
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

public protocol SearchedRegionsAvailabilityType {
    func get() -> [String]
    func set(value: [String])
    func eraseAll()
}

public final class SearchedRegionsAvailability: SearchedRegionsAvailabilityType {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func get() -> [String] {
        return userDefaults.array(forKey: .kSearchedRegionsIdentifiers) as? [String] ?? []
    }

    public func set(value: [String]) {
        userDefaults.set(value, forKey: .kSearchedRegionsIdentifiers)
    }

    public func eraseAll() {
        userDefaults.removeObject(forKey: .kSearchedRegionsIdentifiers)
    }
}

extension String {
    public static let kSearchedRegionsIdentifiers = "kSearchedRegionsIdentifiers"
}
