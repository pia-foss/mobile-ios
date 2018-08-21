//
//  ValidatorTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 20/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import XCTest
@testable import PIALibrary

class ValidatorTests: XCTestCase {
    
    func testValidatorGiftCardIsValid() {
        let giftCode = "1234567812345678"
        XCTAssertTrue(Validator.validate(giftCode: giftCode))
    }
    
    func testValidatorGiftCardIsInvalid() {
        let giftCode = "12345678678"
        XCTAssertFalse(Validator.validate(giftCode: giftCode))
    }
    
}
