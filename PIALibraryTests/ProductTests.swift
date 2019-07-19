//
//  ProductTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 19/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import XCTest
@testable import PIALibrary

class ProductTests: XCTestCase {

    private let mock = MockProviders()
    private let subscriptionProductIds = ["com.privateinternetaccess.subscription.1month",
                                          "com.privateinternetaccess.subscription.1year"]

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPlans() {
        __testRetrieveSubscriptionPlans(webServices: PIAWebServices())
    }

    func testMockProductIdentifiers() {
        let expUpdate = expectation(description: "productIdentifiers")
        mock.accountProvider.updatePlanProductIdentifiers { products, error in
            if let _ = error {
                print("error found: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            guard let _ = products else {
                print("testMockProductIdentifiers: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            expUpdate.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }

    private func __testRetrieveSubscriptionPlans(webServices: PIAWebServices) {
        let exp = expectation(description: "subscription.plans")
        
        webServices.planProductIdentifiers({ products, error in
            
            if let _ = error {
                print("Request error: \(error!)")
                XCTAssert(false)
                exp.fulfill()
                return
            }
            
            if let products = products,
                products.count > 0 {
                XCTAssertEqual(products.count, self.subscriptionProductIds.count)
                XCTAssertEqual(products.first!.identifier, self.subscriptionProductIds.first!)
                XCTAssertEqual(products.last!.identifier, self.subscriptionProductIds.last!)
                exp.fulfill()
            } else {
                XCTAssert(error as? ClientError != ClientError.malformedResponseData, "malformedResponseData")
                XCTAssert(false)
                exp.fulfill()
            }
            
        })
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
}
