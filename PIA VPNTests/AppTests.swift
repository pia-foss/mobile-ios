//
//  AppTests.swift
//  PIA VPNTests
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
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
