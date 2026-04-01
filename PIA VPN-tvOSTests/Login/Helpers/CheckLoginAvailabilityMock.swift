//
//  CheckLoginAvailabilityMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class CheckLoginAvailabilityMock: CheckLoginAvailabilityType {
    private let result: Result<Void, LoginError>
    
    init(result: Result<Void, LoginError>) {
        self.result = result
    }
    
    func disableLoginFor(_ delay: Double) {}
    
    func callAsFunction() -> Result<Void, LoginError> {
        return result
    }
}
