//
//  ConnectionStatsPermisson.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

private extension String {
    static let kConnectionStatsPermisson = "kConnectionStatsPermisson"
}

class ConnectionStatsPermisson: ConnectionStatsPermissonType {
    private let userDefautls: UserDefaults
    
    init(userDefautls: UserDefaults = .standard) {
        self.userDefautls = userDefautls
    }
    
    func get() -> Bool? {
        return userDefautls.object(forKey: .kConnectionStatsPermisson) as? Bool
    }
    
    func set(value: Bool) {
        userDefautls.set(value, forKey: .kConnectionStatsPermisson)
    }
}
