//
//  AccountSignupTests.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 10/22/17.
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

class AccountSignupTests: XCTestCase {
    private var observers = [NSObjectProtocol]()

    private let live = Client.providers

    override func setUp() {
        super.setUp()

        Client.store = MockInAppProvider()
        Client.configuration.setPlan(.monthly, forProductIdentifier: "com.example.first")
        Client.configuration.setPlan(.yearly, forProductIdentifier: "com.example.second")
        Client.database = Client.Database(group: "group.com.privateinternetaccess").truncate()
        Client.bootstrap()
        Client.refreshProducts()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testProducts() {
        if let products = live.accountProvider.planProducts {
            XCTAssertEqual(products.count, 2)
            print("Products cached: \(products)")
        } else {
            let exp = expectation(description: "products")
            let nc = NotificationCenter.default
            var observer: NSObjectProtocol!
            observer = nc.addObserver(forName: .__InAppDidFetchProducts, object: nil, queue: nil) { (notification) in
                nc.removeObserver(observer)
                let products: [Plan: InAppProduct] = notification.userInfo(for: .products)
                XCTAssertEqual(products.count, 2)
                print("Products fetched: \(products)")
                exp.fulfill()
            }
            waitForExpectations(timeout: 10.0, handler: nil)
        }
    }
    
    func testPurchase() {
        let exp = expectation(description: "purchase")
        live.accountProvider.purchase(plan: .yearly) { (transaction, error) in
            XCTAssertNotNil(transaction)
            print("Purchased: \(transaction!)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testGiftCodeSyntax() {
        XCTAssertTrue(Validator.validate(giftCode: "1234123412341234"))
        XCTAssertFalse(Validator.validate(giftCode: "1234123412341234", withDashes: true))
        XCTAssertFalse(Validator.validate(giftCode: "1234-1234-1234-1234"))
        XCTAssertTrue(Validator.validate(giftCode: "1234-1234-1234-1234", withDashes: true))
    }
}
