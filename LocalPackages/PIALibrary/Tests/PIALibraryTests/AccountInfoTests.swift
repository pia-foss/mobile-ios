//
//  AccountInfoTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 14/8/18.
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

class AccountInfoTests: XCTestCase {
    
    private let mock = MockProviders()
    private var theDate: Date!
    private var accountInfo: AccountInfo!

    override func setUp() {
        super.setUp()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.theDate = dateFormatter.date(from: "14-08-2018")
        self.accountInfo = AccountInfo(email: "email@email.com", username: "pXXXXXX",
                                       plan: Plan.monthly,
                                       productId: "identifier",
                                       isRenewable: false,
                                       isRecurring: false,
                                       expirationDate: self.theDate,
                                       canInvite: true,
                                       shouldPresentExpirationAlert: false,
                                       renewUrl: nil)
    }
    
    override func tearDown() {
        self.theDate = nil
        self.accountInfo = nil
        super.tearDown()
    }
    
    public func testExpirationDateDefaultLocale() {
        
        //We are going to asume for the test the default Locale is en_US
        XCTAssertEqual(accountInfo.humanReadableExpirationDate(usingLocale: Locale(identifier: "en_US")),
                       "August 14, 2018",
                       "The human readable format is not correct")
        
    }
    
    public func testExpirationDateUsingSpanishLocale() {
        
        XCTAssertEqual(accountInfo.humanReadableExpirationDate(usingLocale: Locale(identifier: "es_ES")),
                       "14 de agosto de 2018",
                       "The human readable format is not correct")
        
    }

    public func testRenewableProduct() {
        
        Client.providers.accountProvider.logout(nil)
        
        let factory = MockProviders()
        let expLogin = expectation(description: "login")
        let credentials = Credentials(username: "p0000000", password: "foobarbogus")
        
        Client.providers.accountProvider.login(with: LoginRequest(credentials: credentials)) { (user, error) in
            guard let _ = user else {
                print("Login error: \(error!)")
                expLogin.fulfill()
                XCTAssert(false)
                return
            }
            XCTAssert(factory.accountProvider.isLoggedIn)
            XCTAssertEqual(user?.isRenewable, false)
            XCTAssertEqual(user?.info?.isRecurring, true)
            expLogin.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
}
