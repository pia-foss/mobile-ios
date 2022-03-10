//
//  PIALoginTests.swift
//  PIA VPN UITests
//
//  Created by Waleed Mahmood on 01.03.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
import Pods_PIA_VPN_dev

class PIALoginTests: XCTestCase {
    
    static let timeoutUIOps: TimeInterval = 10.0
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        navigateToGetStartedViewController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func assertfalse(with message: String) {
        XCTAssert(false, message)
    }
    
    private func navigateToGetStartedViewController() {
        // wait 5 second for Dashboard to settle down
        sleep(5)
        
        // check if we have a side menu
        if app.navigationBars.buttons[Accessibility.UITests.Dashboard.menu].exists {
            openSideMenuAndTapLogout()
        }
    }
    
    private func openSideMenuAndTapLogout() {
        app.navigationBars.buttons[Accessibility.UITests.Dashboard.menu].tap()
        
        if app.cells[Accessibility.UITests.Menu.logout].waitForExistence(timeout: PIALoginTests.timeoutUIOps) {
            app.cells[Accessibility.UITests.Menu.logout].tap()
        } else {
            assertfalse(with: "PIALoginTests:: A side menu is found but no logout cell is found")
        }
        if app.buttons[Accessibility.UITests.Dialog.destructive].waitForExistence(timeout: PIALoginTests.timeoutUIOps) {
            app.buttons[Accessibility.UITests.Dialog.destructive].tap()
        } else {
            assertfalse(with: "PIALoginTests:: Logout alert destructive button is not found")
        }
    }
    
    private func navigateToLoginViewController() {
        var isNewButtonUsed = false
        
        // wait for feature flags
        var submitButtonExists = app.buttons[Accessibility.UITests.Login.submit].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        
        // check if new button should be used
        if !submitButtonExists {
            submitButtonExists = app.buttons[Accessibility.UITests.Login.submitNew].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
            isNewButtonUsed = true
        }
        
        if submitButtonExists {
            if submitButtonExists && !isNewButtonUsed {
                app.buttons[Accessibility.UITests.Login.submit].tap()
            } else {
                app.buttons[Accessibility.UITests.Login.submitNew].tap()
            }
            
        } else {
            assertfalse(with: "PIALoginTests:: One of the Login buttons on GetStartedViewController is either not identifiable or have been moved")
        }
    }
    
    private func fillLoginScreen(with credentials: Credentials) {
        let usernameTextField = app.textFields[Accessibility.UITests.Login.username]
        let passwordTextField = app.secureTextFields[Accessibility.UITests.Login.password]
        
        if usernameTextField.exists && passwordTextField.exists {
            // Type username
            usernameTextField.tap()
            usernameTextField.typeText(credentials.username)
            
            // Type password
            passwordTextField.tap()
            passwordTextField.typeText(credentials.password)
        } else {
            assertfalse(with: "PIALoginTests:: Username and Password text fields on LoginViewController are either not identifiable or are moved")
        }
    }
    
    private func loginUser(ofType: CredentialsType) {
        navigateToLoginViewController()
        switch ofType {
        case .valid:
            fillLoginScreen(with: CredentialsUtil.credentials(type: .valid))
        case .expired:
            fillLoginScreen(with: CredentialsUtil.credentials(type: .expired))
        case .invalid:
            fillLoginScreen(with: CredentialsUtil.credentials(type: .invalid))
        }
        
        let loginButton = app.buttons[Accessibility.UITests.Login.submit]
        loginButton.tap()
    }
    
    func testInvalidUserLogin() throws {
        loginUser(ofType: .invalid)
        
        let bannerViewExists = app.staticTexts["Your username or password is incorrect."].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        XCTAssertTrue(bannerViewExists, "PIALoginTests::testInvalidUserLogin() failed")
    }
    
    func testExpiredUserLogin() throws {
        app.switchEnvironment(to: .staging)
        loginUser(ofType: .expired)
        
        let bannerViewExists = app.staticTexts["Your username or password is incorrect."].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        XCTAssertTrue(bannerViewExists, "PIALoginTests::testExpiredUserLogin() failed")
    }
    
    func testValidUserLogin() throws {
        app.switchEnvironment(to: .production)
        loginUser(ofType: .valid)

        let viewTitleExists = app.staticTexts["PIA needs access to your VPN profiles to secure your traffic"].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        let okButtonExist = app.buttons[Accessibility.UITests.Permissions.submit].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        XCTAssertTrue(viewTitleExists && okButtonExist, "PIALoginTests::testActiveUserLogin() failed")
    }
}

private extension XCUIApplication {
    
    func switchEnvironment(to environment: Client.Environment) {
        // wait until the button is available
        _ = self.buttons[Accessibility.UITests.Welcome.environment].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        let environmentButton = self.buttons[Accessibility.UITests.Welcome.environment]
        
        if environmentButton.label.lowercased() != environment.rawValue.lowercased() {
            
            // then click it to switch environment
            environmentButton.tap()
        }
    }
}
