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
        app.launch()
        app.logOutIfNeeded()
        
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testSignInWithValidCredentials() throws {
        // GIVEN that valid credentials are provided in the login screen
        navigateToLoginScreen()
        fillLoginScreen(with: CredentialsUtil.credentials(type: .valid))
        
        // WHEN tapping the 'Login' button
        app.loginButton.tap()
        
        // THEN the Vpn Permission screen will appear
        XCTAssertTrue(app.willDisplayVpnPermissionScreen)
        
        // AND no login error banner is displayed
        XCTAssertFalse(app.isDisplayingLoginErrorBanner)
    }
    
    func testSignInWithInvalidCredentials() throws {
        // GIVEN that invalid credentials are provided in the login screen
        navigateToLoginScreen()
        fillLoginScreen(with: CredentialsUtil.credentials(type: .invalid))
        
        // WHEN tapping the 'Login' button
        app.loginButton.tap()
        
        // THEN the login error banner is displayed
        XCTAssertTrue(app.willDisplayLoginErrorBanner)
        
        // AND the app does NOT display the Vpn Permission Screen
        XCTAssertFalse(app.willDisplayVpnPermissionScreen)
    }
    
    func testBDDSignInWithValidCredentials() throws {
        // GIVEN that valid credentials are provided in the login screen
        XCTContext.runActivity(named: "GIVEN that valid credentials are provided in the login screen") { _ in
            navigateToLoginScreen()
            fillLoginScreen(with: CredentialsUtil.credentials(type: .valid))
        }
        
        XCTContext.runActivity(named: "WHEN tapping the 'Login' button") { _ in
            app.loginButton.tap()
        }
        
        XCTContext.runActivity(named: "THEN the VPN Permission screen will appear") { _ in
            XCTAssertTrue(app.willDisplayVpnPermissionScreen)
        }
        
        
        XCTContext.runActivity(named: "AND no login error banner is displayed") { _ in
        
            XCTAssertFalse(app.isDisplayingLoginErrorBanner)
        }
        
    }
    
    func testBDDSignInWithInvalidCredentials() throws {
        XCTContext.runActivity(named: "GIVEN that invalid credentials are provided in the login screen") { _ in
            navigateToLoginScreen()
            fillLoginScreen(with: CredentialsUtil.credentials(type: .invalid))
        }
        
        XCTContext.runActivity(named: "WHEN tapping the 'Login' button") { _ in
            app.loginButton.tap()
        }
        
        XCTContext.runActivity(named: "THEN the login error banner is displayed") { _ in
            XCTAssertTrue(app.willDisplayLoginErrorBanner)
        }
        
        XCTContext.runActivity(named: "AND the app does NOT display the Vpn Permission Screen") { _ in
            XCTAssertFalse(app.willDisplayVpnPermissionScreen)
        }
    }
    
}

// MARK: Private methods

extension PIASignInE2ETests {
    
    private func navigateToLoginScreen() {
        if app.goToLoginScreenButton.waitForExistence(timeout: app.shortTimeout) {
            app.goToLoginScreenButton.tap()
        } else {
            XCTFail("PIASigninE2ETests: Login button not found when trying to navigate to login screen")
        }
    }
    
    private func fillLoginScreen(with credentials: Credentials) {
        let usernameTextField = app.textField(with: PIALibraryAccessibility.Id.Login.username)
        
        let passwordTextField = app.secureTextField(with: PIALibraryAccessibility.Id.Login.password)
        
        if usernameTextField.exists && passwordTextField.exists {
            // Type username
            usernameTextField.tap()
            usernameTextField.typeText(credentials.username)
            
            // Type password
            passwordTextField.tap()
            passwordTextField.typeText(credentials.password)
        } else {
            XCTFail("PIASigninE2ETests: Username and Password text fields on LoginViewController are either not identifiable or are moved")
        }
    }
}

