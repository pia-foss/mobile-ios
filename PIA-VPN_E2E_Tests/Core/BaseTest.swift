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

class BaseTest: QuickSpec {
    static var app: XCUIApplication!
    
    override class func spec() {
        beforeSuite {
            app = XCUIApplication()
            app.launch()
            if(!app.connectionButton.waitForExistence(timeout: app.defaultTimeout)) {
                app.navigateToLoginScreen()
                app.logIn(with: CredentialsUtil.credentials(type: .valid))
                app.acceptVPNPermission()
            }
        }
        
        beforeEach {
            app.launch()
            if(!app.connectionButton.waitForExistence(timeout: app.defaultTimeout)) {
                app.navigateToLoginScreen()
                app.logIn(with: CredentialsUtil.credentials(type: .valid))
                app.acceptVPNPermission()
            }
        }
        
        afterEach {
            app.terminate()
        }
        
        afterSuite {
            app.terminate()
        }
    }
}
