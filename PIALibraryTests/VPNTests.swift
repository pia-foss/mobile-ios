//
//  VPNTests.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
    
//    func testInstall() {
//        Client.providers.vpnProvider.install(profile: <#T##VPNProfile#>, completionHandler: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//    }
    
    func testCompression() {
        let orig = "This is a test"
        let deflated = (orig.data(using: .utf8)! as NSData).deflated()! as NSData
        print("Deflated: \(deflated)")
        let reinflated = String(data: deflated.inflated()!, encoding: .utf8)
        
        XCTAssertEqual(orig, reinflated)
    }

    func testDebugLogSubmission() {
        let content = "2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)\n2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)"
        let log = PlatformVPNLog(rawContent: content)
    
        let exp = expectation(description: "Debug submission")
        PIAWebServices().submitDebugLog(log) { (error) in
            if let error = error {
                print("Debug log not submitted: \(error)")
                return
            }
            print("Debug id: \(log.identifier)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
