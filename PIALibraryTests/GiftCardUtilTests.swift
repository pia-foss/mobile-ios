//
//  GiftCardUtilTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 20/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
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
