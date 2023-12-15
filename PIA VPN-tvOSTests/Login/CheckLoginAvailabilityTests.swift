//
//  CheckLoginAvailabilityTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class CheckLoginAvailabilityTests: XCTestCase {
    
    func test_checkLoginAvailability_returns_success_when_there_is_no_delay() {
        // GIVEN
        let sut = CheckLoginAvailability()
        
        // WHEN
        let result = sut()
        
        // THEN
        guard case .success = result else {
            XCTFail("Expected success, got failure")
            return
        }
    }

    func test_checkLoginAvailability_returns_success_when_delay_expired() {
        // GIVEN
        let sut = CheckLoginAvailability()
        
        // WHEN
        sut.disableLoginFor(Date().timeIntervalSince1970 - 1)
        let result = sut()
        
        // THEN
        guard case .success = result else {
            XCTFail("Expected success, got failure")
            return
        }
    }
    
    func test_checkLoginAvailability_returns_failure_when_delay_has_not_expired_yet() {
        // GIVEN
        let date = Date()
        let sut = CheckLoginAvailability()
        
        // WHEN
        sut.disableLoginFor(date.timeIntervalSince1970 + 10)
        let result = sut()
        
        // THEN
        guard case .failure(let error) = result else {
            XCTFail("Expected success, got failure")
            return
        }
    
        guard case .throttled = error else {
            XCTFail("Expected throttled error, got \(error)")
            return
        }
    }
}
