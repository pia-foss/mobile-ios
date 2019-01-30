//
//  AppTests.swift
//  PIA VPNTests
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN

class AppTests: XCTestCase {

    func testCompression() {
        let orig = "This is a test"
        if let data = orig.data(using: .utf8) {
            let nsData = NSData(data: data)
            if let deflated = nsData.deflated() {
                let nsDataInflated = NSData(data: deflated)
                let reinflated = String(data: nsDataInflated.inflated(), encoding: .utf8)
                XCTAssertEqual(orig, reinflated)
            } else {
                XCTAssert(false)
            }
        } else {
            XCTAssert(false)
        }
    }

}
