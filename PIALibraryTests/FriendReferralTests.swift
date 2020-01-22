//
//  FriendReferralTests.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 02/08/2019.
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

class FriendReferralTests: XCTestCase {

    private let mock = MockProviders()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFriendReferral() {
        
        let expInviteInformation = expectation(description: "invitesInformation")
        
        Client.providers.accountProvider.invitesInformation( { (invites, error) in
            guard let _ = invites else {
                print("invites information error: \(error!)")
                expInviteInformation.fulfill()
                XCTAssert(false)
                return
            }
            
            XCTAssertNotNil(invites?.uniqueReferralLink, "referral link cant be nil")
            expInviteInformation.fulfill()
        })

        waitForExpectations(timeout: 5.0, handler: nil)

    }
    
    func testInviteFriends() {
        __testLogin(factory: mock)
        __testInviteFriend()
        __testInviteFriendInvalidEmail()
        __testLogout(factory: mock)
    }
    
    func __testInviteFriend() {
        
        let expInvite = expectation(description: "inviteFriend")
        
        Client.providers.accountProvider.invite(name: "John", email: "qwerty@keyboard.com", { error in

            XCTAssertNil(error, "error should be nil")
            expInvite.fulfill()

        })
        
        waitForExpectations(timeout: 5.0, handler: nil)

    }
    
    func __testInviteFriendInvalidEmail() {
        
        let expInvite = expectation(description: "inviteFriend")
        
        Client.providers.accountProvider.invite(name: "John", email: "", { error in
            
            XCTAssertNotNil(error, "should raise a .invalidParameter error")
            expInvite.fulfill()
            
        })
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }

    private func __testLogin(factory: Client.Providers) {
        let expLogin = expectation(description: "login")
        let credentials = Credentials(username: "p0000000", password: "foobarbogus")
        
        factory.accountProvider.login(with: LoginRequest(credentials: credentials)) { (user, error) in
            guard let _ = user else {
                print("Login error: \(error!)")
                expLogin.fulfill()
                XCTAssert(false)
                return
            }
            XCTAssert(factory.accountProvider.isLoggedIn)
            XCTAssertNotNil(factory.accountProvider.currentUser)
            print("Logged in with: \(factory.accountProvider.currentUser!)")
            expLogin.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    private func __testLogout(factory: Client.Providers) {
        let expLogout = expectation(description: "logout")
        factory.accountProvider.logout { (error) in
            if let error = error {
                print("Logout error: \(error)")
                expLogout.fulfill()
                XCTAssert(false)
                return
            }
            XCTAssert(!factory.accountProvider.isLoggedIn)
            XCTAssertNil(factory.accountProvider.currentUser)
            XCTAssertNil(factory.accountProvider.currentUser?.info)
            print("Logged out")
            expLogout.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
