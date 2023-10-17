//
//  BaseTest.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Quick
import Nimble
import XCTest
import Foundation

class BaseTest: QuickSpec{
    static var app: XCUIApplication!
    
    override class func spec(){
        beforeEach {
            app = XCUIApplication()
            app.launch()
            app.logOutIfNeeded()
            app.navigateToLoginScreenIfNeeded()
        }
        
        afterEach {
            app.terminate()
        }
    }
}
