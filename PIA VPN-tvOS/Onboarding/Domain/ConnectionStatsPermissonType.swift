//
//  ConnectionStatsPermissonType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol ConnectionStatsPermissonType {
    func get() -> Bool?
    func set(value: Bool)
}
