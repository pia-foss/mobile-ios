//
//  ProductTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 19/07/2019.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
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

    func testMockProductIdentifiers() {
        let expUpdate = expectation(description: "productIdentifiers")
        mock.accountProvider.subscriptionInformation { subscriptionInfo, error in
            if let _ = error {
                print("error found: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            guard let _ = subscriptionInfo else {
                print("testMockProductIdentifiers: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            expUpdate.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testMockTrialsUserNotEligible() {
        let expUpdate = expectation(description: "trials")
        mock.accountProvider.subscriptionInformation { subscriptionInfo, error in
            if let _ = error {
                print("error found: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            guard let _ = subscriptionInfo else {
                print("testMockTrials: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            XCTAssertFalse(Client.configuration.eligibleForTrial)
            expUpdate.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }

    func testMockTrialsUserEligible() {
        Client.useMockInAppProviderWithoutReceipt()
        let expUpdate = expectation(description: "trials")
        mock.accountProvider.subscriptionInformation { subscriptionInfo, error in
            if let _ = error {
                print("error found: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            guard let _ = subscriptionInfo else {
                print("testMockTrials: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            XCTAssertTrue(Client.configuration.eligibleForTrial)
            expUpdate.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testMockTrialsUserEligibleButTrialsDisabledOnBackend() {
        Client.useMockInAppProviderWithReceipt()
        let expUpdate = expectation(description: "trials_disabled_from_backend")
        mock.accountProvider.subscriptionInformation { subscriptionInfo, error in
            if let _ = error {
                print("error found: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            guard let _ = subscriptionInfo else {
                print("testMockTrials: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            XCTAssertFalse(Client.configuration.eligibleForTrial)
            expUpdate.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    
}
