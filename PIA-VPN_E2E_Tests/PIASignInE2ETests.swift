//
//  PIASignInE2ETests.swift
//  PIASignInE2ETests
//
//  Created by Laura S on 10/3/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest


final class PIASignInE2ETests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Handles any possible interruption in the test
        // due to the appearence of a permission system alert
        // (like Notifications permission, VPN profile installation, etc.)
        app.dismissAnyPermissionSystemAlert(from: self)
        
        app.launch()
        
        app.logOutIfNeeded()
        app.navigateToLoginScreenIfNeeded()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testSignInWithValidCredentials() throws {
        XCTContext.runActivity(named: "GIVEN that valid credentials are provided in the login screen") { _ in
            app.fillLoginScreen(with: CredentialsUtil.credentials(type: .valid))
        }
        
        XCTContext.runActivity(named: "WHEN tapping the 'Login' button") { _ in
            app.loginButton.tap()
        }
        
        XCTContext.runActivity(named: "THEN the VPN Permission screen will appear") { _ in
            XCTAssertTrue(app.vpnPermissionScreen.waitForExistence(timeout: app.defaultTimeout))
        }
        
        XCTContext.runActivity(named: "AND no login error banner is displayed") { _ in
            XCTAssertFalse(app.loginErrorMessage.exists)
        }
        
    }
    
    func testSignInWithInvalidCredentials() throws {
        XCTContext.runActivity(named: "GIVEN that invalid credentials are provided in the login screen") { _ in
            app.fillLoginScreen(with: CredentialsUtil.credentials(type: .invalid))
        }
        
        XCTContext.runActivity(named: "WHEN tapping the 'Login' button") { _ in
            app.loginButton.tap()
        }
        
        XCTContext.runActivity(named: "THEN the login error banner is displayed") { _ in
            XCTAssertTrue(app.loginErrorMessage.waitForExistence(timeout: app.shortTimeout))
        }
        
        XCTContext.runActivity(named: "AND the app does NOT display the Vpn Permission Screen") { _ in
            XCTAssertFalse(app.vpnPermissionScreen.exists)
        }
    }
    
}

