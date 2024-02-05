//
//  SearchedRegionsAvailabilityMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class SearchedRegionsAvailabilityMock: SearchedRegionsAvailabilityType {
    
    var getCalled = false
    var getCalledAttempt = 0
    var getResult:[String] = []
    func get() -> [String] {
        getCalled = true
        getCalledAttempt += 1
        return getResult
    }
    
    
    var setCalled = false
    var setCalledAttepmt = 0
    var setCalledWithArgument: [String]!
    func set(value: [String]) {
        setCalled = true
        setCalledAttepmt += 1
        setCalledWithArgument = value
    }
    
    
}
