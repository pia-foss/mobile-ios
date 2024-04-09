//
//  BaseTest.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Foundation

class BaseTest:QuickSpec {
    static var app: XCUIApplication!
    
    override class func spec() {
        beforeSuite {
            app = XCUIApplication()
            app.launch()
            
            if(app.helpImprovePIATitle.exists){
                app.acceptSharingVPNStats()
                app.acceptVPNConfiguration()
            }
            
            if(!app.connectButton.exists){
                app.signinImage.waitForElementToAppear()
                app.navigateToSignInScreen()
                app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
                app.acceptSharingVPNStats()
                app.acceptVPNConfiguration()
            }
        }
        
        beforeEach {
            app.launch()
            
            if(app.helpImprovePIATitle.exists){
                app.acceptSharingVPNStats()
                app.acceptVPNConfiguration()
            }
        }
        
        afterEach {
            app.terminate()
        }
    }
}
