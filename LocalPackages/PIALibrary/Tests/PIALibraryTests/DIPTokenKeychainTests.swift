//
//  DIPTokenKeychainTests.swift
//  PIALibrary
//  
//  Created by Jose Blaya on 16/10/2020.
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
@testable import PIALibrary

class DIPTokenKeychainTests: XCTestCase {

    override class func setUp() {
        Client.database.secure.removeDIPTokens()
    }
    
    func testAddDipToken() throws {

        Client.database.secure.setDIPToken("token_1")
        XCTAssertTrue(Client.database.secure.dipTokens()?.count == 1)
        
    }

    func testAddMultipleDipTokens() throws {
        
        Client.database.secure.setDIPToken("token_1")
        Client.database.secure.setDIPToken("token_2")
        Client.database.secure.setDIPToken("token_3")
        XCTAssertTrue(Client.database.secure.dipTokens()?.count == 3)
        
    }
    
    func testAddSameDipToken() throws {
        
        Client.database.secure.setDIPToken("token_1")
        Client.database.secure.setDIPToken("token_1")
        XCTAssertTrue(Client.database.secure.dipTokens()?.count == 1)
        
    }
    
    func testRemoveAllTokens() throws {
        
        Client.database.secure.setDIPToken("token_1")
        Client.database.secure.setDIPToken("token_2")
        Client.database.secure.setDIPToken("token_3")
        XCTAssertTrue(Client.database.secure.dipTokens()?.count == 3)
        Client.database.secure.removeDIPTokens()
        XCTAssertTrue(Client.database.secure.dipTokens() == nil)

    }
    
    func testRemoveSpecificTokens() throws {
        
        Client.database.secure.setDIPToken("token_1")
        Client.database.secure.setDIPToken("token_2")
        Client.database.secure.setDIPToken("token_3")
        XCTAssertTrue(Client.database.secure.dipTokens()?.count == 3)
        Client.database.secure.remove("token_2")
        XCTAssertTrue(Client.database.secure.dipTokens()?[0] == "token_1")
        XCTAssertTrue(Client.database.secure.dipTokens()?[1] == "token_3")

    }
    
}
