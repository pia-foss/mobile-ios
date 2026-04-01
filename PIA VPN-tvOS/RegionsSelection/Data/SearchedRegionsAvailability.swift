//
//  SearchedRegionsAvailability.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/30/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol SearchedRegionsAvailabilityType {
    func get() -> [String]
    func set(value: [String])
    func eraseAll()
}


class SearchedRegionsAvailability: SearchedRegionsAvailabilityType {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func get() -> [String] {
        return userDefaults.array(forKey: .kSearchedRegionsIdentifiers) as? [String] ?? []
    }
    
    func set(value: [String]) {
        userDefaults.set(value, forKey: .kSearchedRegionsIdentifiers)
    }
    
    func eraseAll() {
        userDefaults.removeObject(forKey: .kSearchedRegionsIdentifiers)
    }
}


extension String {
    static let kSearchedRegionsIdentifiers = "kSearchedRegionsIdentifiers"
}
