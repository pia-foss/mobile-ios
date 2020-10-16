//
//  AccountTests.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 10/1/17.
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

class AccountTests: XCTestCase {
    private var observers = [NSObjectProtocol]()

    private let mock = MockProviders()
    
    private let live = Client.providers
    
    override func setUp() {
        super.setUp()

        registerNotifications()

        Client.database = Client.Database(group: "group.com.privateinternetaccess").truncate()
        Client.bootstrap()
        Client.providers.accountProvider.cleanDatabase()

    }
    
    override func tearDown() {
        super.tearDown()
        
        unregisterNotifications()
    }
    
    func testMockLogin() {
        __testLogin(factory: mock)
    }
    
    func testMockUpdate() {
        __testLogin(factory: mock)
        __testUpdate(factory: mock)
    }
    
    func testMockLogout() {
        __testLogin(factory: mock)
        __testLogout(factory: mock)
    }
    
    func testMock() {
        __testLogin(factory: mock)
        __testUpdate(factory: mock)
        __testLogout(factory: mock)
    }
        
    func testAPIEndpointIsReachable() {
        
        let expectationAPIEndpoint = expectation(description: "apiEndpoint")

        mock.accountProvider.isAPIEndpointAvailable { (result, error) in
            XCTAssertTrue(result!, "The default API endpoint should be reachable from the tests")
            expectationAPIEndpoint.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)

    }
    
    /*func testWeb() {
        __testLogin(factory: live)
        sleep(1)
        __testUpdate(factory: live)
        sleep(1)
        __testLogout(factory: live)
    }*/
    
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
            print("Logged in with: \(factory.accountProvider.currentUser)")
            expLogin.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    private func __testUpdate(factory: Client.Providers) {
        let expUpdate = expectation(description: "update")
        let newEmail = "foobar+\(arc4random())@example.com"
        factory.accountProvider.update(with: UpdateAccountRequest(email: newEmail), resetPassword: false, andPassword: "password") { (accountInfo, error) in
            guard let _ = accountInfo else {
                print("Update error: \(error!)")
                expUpdate.fulfill()
                XCTAssert(false)
                return
            }
            XCTAssert(factory.accountProvider.isLoggedIn)
            XCTAssertNotNil(factory.accountProvider.currentUser)
            XCTAssertEqual(factory.accountProvider.currentUser?.info?.email, newEmail)
            print("Updated account info: \(factory.accountProvider.currentUser!.info!)")
            expUpdate.fulfill()
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

    private func registerNotifications() {
        let nc = NotificationCenter.default
        observers.append(nc.addObserver(forName: .PIAAccountDidLogin, object: nil, queue: nil) { (notification) in
            print("Login succeeded")
            print("\tUser: \(notification.userInfo(for: .user) as UserAccount)")
        })
        observers.append(nc.addObserver(forName: .PIAAccountDidUpdate, object: nil, queue: nil) { (notification) in
            print("Account updated")
            print("\tInfo: \(notification.userInfo(for: .accountInfo) as AccountInfo)")
        })
        observers.append(nc.addObserver(forName: .PIAAccountDidRefresh, object: nil, queue: nil) { (notification) in
            print("Account refreshed")
        })
        observers.append(nc.addObserver(forName: .PIAAccountDidLogout, object: nil, queue: nil) { (notification) in
            print("Logged out")
        })
    }
    
    private func unregisterNotifications() {
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
}
