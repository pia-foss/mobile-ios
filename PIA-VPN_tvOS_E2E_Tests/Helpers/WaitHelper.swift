//
//  WaitHelper.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 12/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
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
}
