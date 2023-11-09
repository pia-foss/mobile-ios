//
//  PIACardTests.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/07/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


import XCTest
import PIALibrary
@testable import PIA_VPN

class PIACardTests: XCTestCase {

    func testCards() throws {

        let appVersion = "3.7.1"

        let cards = CardFactory.getCardsForVersion(appVersion)
        XCTAssertTrue(cards.count == 1, "one card for version 3.7.1")

    }

    func testCardsInvalidVersion() throws {

        let appVersion = "1.7.1"

        let cards = CardFactory.getCardsForVersion(appVersion)
        XCTAssertTrue(cards.count == 0, "no cards for 1.7.1")

    }
    
    
}
