//
//  ConnectionStatsPermissonMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class ConnectionStatsPermissonMock: ConnectionStatsPermissonType {
    var settedValues = [Bool]()
    private let value: Bool?
    
    init(value: Bool?) {
        self.value = value
    }
    
    func get() -> Bool? {
        return value
    }
    
    func set(value: Bool?) {
        if let value = value {
            settedValues.append(value)
        }
    }
}
