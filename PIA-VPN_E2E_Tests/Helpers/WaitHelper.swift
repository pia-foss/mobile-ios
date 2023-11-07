//
//  WaitHelper.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

enum ElementError: Error, CustomStringConvertible{
    case visibilityTimeout
    case invisibilityTimeout
    
    var description: String{
        switch self{
        case .visibilityTimeout:
            return "Element visibility check timed out."
        case .invisibilityTimeout:
            return "Element invisibility check timed out."
        }
    }
}

class WaitHelper{
    static var app: XCUIApplication!
    
    static func waitForElementToBeVisible(_ element:XCUIElement,timeout: TimeInterval = app.defaultTimeout, onSuccess:() -> Void, onFailure:(ElementError) -> Void){
        let predicate = NSPredicate(format:"exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        if result == .completed {
            onSuccess()
        }
        
        else{
            onFailure(.visibilityTimeout)
        }
    }
    
    static func waitForElementToNotBeVisible(_ element:XCUIElement, timeout: TimeInterval = app.defaultTimeout, onSuccess:() -> Void, onFailure:(ElementError) -> Void){
        let predicate = NSPredicate(format:"exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        if result == .completed {
            onSuccess()
        }
        
        else{
            onFailure(.invisibilityTimeout)
        }
    }
}
