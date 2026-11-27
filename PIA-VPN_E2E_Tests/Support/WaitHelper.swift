//
//  WaitHelper.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIElement {
    @discardableResult
    func waitForElementToAppear(timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    @discardableResult
    func waitForElementToBeHidden(timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
