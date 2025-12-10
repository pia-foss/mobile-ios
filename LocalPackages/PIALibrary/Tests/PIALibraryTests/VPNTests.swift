//
//  VPNTests.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 12/13/17.
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
import __PIALibraryNative

class VPNTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        Client.database = Client.Database(group: "group.com.privateinternetaccess")
        Client.providers.vpnProvider = MockVPNProvider()

        let prefs = Client.preferences.editable()
        prefs.vpnDisconnectsOnSleep = true
        prefs.commit()

        Client.bootstrap()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCompression() {
        let orig = "This is a test"
        let deflated = (orig.data(using: .utf8)! as NSData).deflated()! as NSData
        print("Deflated: \(deflated)")
        let reinflated = String(data: deflated.inflated()!, encoding: .utf8)
        
        XCTAssertEqual(orig, reinflated)
    }

    func _testDebugLogSubmission() {
        let content = "2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)\n2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)"
    
        let exp = expectation(description: "Debug submission")
        PIAWebServices().submitDebugReport(false, content) { (reportIdentifier, error) in
            if let error = error {
                print("Debug log not submitted: \(error)")
                return
            }
            print("Debug id: \(reportIdentifier)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
