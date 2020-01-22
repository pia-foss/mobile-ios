//
//  GiftCardUtilTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 20/8/18.
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

class GiftCardUtilTests: XCTestCase {
    
    func testGiftCardUtilFormattedCode() {
        let giftCode = "1234567812345678"
        XCTAssertEqual(GiftCardUtil.friendlyRedeemCode(giftCode),
                       "1234-5678-1234-5678")
    }
    
    func testGiftCardUtilStrippedRedeemCode() {
        let giftCode = "1234-5678-1234-5678"
        XCTAssertEqual(GiftCardUtil.strippedRedeemCode(giftCode),
                       "1234567812345678")
    }
    
    func testExtractRedeemCode() {
        
        var giftCode = "1234567812345678"
        XCTAssertEqual(GiftCardUtil.extractRedeemCode(giftCode),
                       "1234567812345678")
        giftCode = "1234#5678-1234#5678"
        XCTAssertNil(GiftCardUtil.extractRedeemCode(giftCode))

        giftCode = "hello the redeem code is 1234567812345678"
        XCTAssertEqual(GiftCardUtil.extractRedeemCode(giftCode),
                       "1234567812345678")

        giftCode = "{redeemCode: \"1234-5678-1234-5678\", user: \"testuser\"}"
        XCTAssertEqual(GiftCardUtil.extractRedeemCode(giftCode),
                       "1234-5678-1234-5678")
        
        XCTAssertEqual(GiftCardUtil.extractRedeemCode(giftCode, strippedFormat: true),
                       "1234567812345678")

    }

}
