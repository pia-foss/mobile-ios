//
//  CheckLoginAvailability.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol CheckLoginAvailabilityType {
    func disableLoginFor(_ delay: Double)
    func callAsFunction() -> Result<Void, LoginError>
}

class CheckLoginAvailability: CheckLoginAvailabilityType {
    private var timeToRetryCredentials: TimeInterval? = nil
    
    func disableLoginFor(_ delay: Double) {
        timeToRetryCredentials = delay
    }
    
    func callAsFunction() -> Result<Void, LoginError> {
        if let timeUntilNextTry = timeToRetryCredentials?.timeSinceNow() {
            return .failure(.throttled(retryAfter: timeUntilNextTry))
        }
        
        return .success(())
    }
}
