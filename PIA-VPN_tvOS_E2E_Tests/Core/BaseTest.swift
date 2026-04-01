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
    static let bundle = Bundle(for: BaseTest.self)
    static var shouldLogIn = true
    
//    override class func spec() {
//        beforeSuite {
//            app = XCUIApplication()
//            app.launch()
//            
//            if(app.helpImprovePIATitle.exists){
//                app.acceptSharingVPNStats()
//                app.acceptVPNConfiguration()
//            }
//            
//            if(shouldLogIn){
//                if (!app.connectButton.exists)
//                {
//                    app.signinImage.waitForElementToAppear()
//                    app.navigateToSignInScreen()
//                    app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
//                    app.acceptSharingVPNStats()
//                    app.acceptVPNConfiguration()
//                }
//            }
//        }
//        
//        beforeEach {
//            app.launch()
//            
//            if(app.helpImprovePIATitle.exists){
//                app.acceptSharingVPNStats()
//                app.acceptVPNConfiguration()
//            }
//        }
//        
//        afterEach {
//            app.terminate()
//        }
//    }
    
    override class func spec() {
        beforeEach {
            initializeApp()
            configureAppSettings()
            attemptLoginIfNeeded()
        }
              
        afterEach {
              terminateApp()
        }
    }
    
    static func initializeApp() {
        app = XCUIApplication()
        app.launch()
    }

    static func configureAppSettings() {
        if app.helpImprovePIATitle.exists {
            app.acceptSharingVPNStats()
            app.acceptVPNConfiguration()
        }
    }

    static func attemptLoginIfNeeded() {
        if shouldLogIn && !app.connectButton.exists {
            performLoginProcess()
        }
    }

    static func performLoginProcess() {
        let signInImageAppeared = app.signinImage.waitForElementToAppear(timeout: 5)
        assert(signInImageAppeared, "Sign-in image did not appear")

        app.navigateToSignInScreen()
        app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
        app.acceptSharingVPNStats()
        app.acceptVPNConfiguration()
    }

    static func relaunchApp() {
        app.launch()
        configureAppSettings()
    }

    static func terminateApp() {
        app.terminate()
    }
}
