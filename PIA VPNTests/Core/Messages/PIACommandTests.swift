//
//  PIACommandTests.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 11/11/2020.
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
import PIAAccount
@testable import PIA_VPN

class PIACommandTests: XCTestCase {

    private let testOVPNAction = InAppMessage(withMessage: ["en" : "This is a message"], id: "1", link: ["en" : "message"], type: .action, level: .api, actions: ["ovpn":true], view: nil, uri: nil)
    private let testNMTAction = InAppMessage(withMessage: ["en" : "This is a message"], id: "1", link: ["en" : "message"], type: .action, level: .api, actions: ["nmt":true], view: nil, uri: nil)

    override func setUpWithError() throws {

        Client.useMockAccountProvider()
        AppPreferences.shared.dismissedMessages = []

        let pref = Client.preferences.editable()
        pref.reset()
        pref.commit()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadMessages() throws {

        MessagesManager.shared.refreshMessages()
        XCTAssertNotNil(MessagesManager.shared.availableMessage())
        
    }
    
    func testDismissMessages() throws {
        
        MessagesManager.shared.refreshMessages()
        XCTAssertNotNil(MessagesManager.shared.availableMessage())

        let availableMessage = MessagesManager.shared.availableMessage()
        
        MessagesManager.shared.dismiss(message: availableMessage!.id)
        
        MessagesManager.shared.refreshMessages()
        XCTAssertNil(MessagesManager.shared.availableMessage())
        
    }
    
    func testCommandAction() throws {
        
        XCTAssertTrue(Client.preferences.vpnType == IKEv2Profile.vpnType)
        
        testOVPNAction.executeAction()
        
        XCTAssertTrue(Client.preferences.vpnType == PIATunnelProfile.vpnType)
            
    }

    func testCommandNMTAction() throws {
        
        XCTAssertTrue(Client.preferences.nmtRulesEnabled == false)
        
        testNMTAction.executeAction()
        
        XCTAssertTrue(Client.preferences.nmtRulesEnabled == true)
        XCTAssertTrue(Client.preferences.isPersistentConnection == true)

    }

}
