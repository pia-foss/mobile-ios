//
//  BaseTest.swift
//  PIA VPN-tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
import XCTest

class BaseTest: QuickSpec {
    static var app: XCUIApplication!
    
    override class func spec() {
        beforeSuite {
            app = XCUIApplication()
            app.launch()
        }
        
        beforeEach {
            app.launch()
        }
        
        afterEach {
            app.terminate()
        }
        
        afterSuite {
            app.terminate()
        }
    }
}

