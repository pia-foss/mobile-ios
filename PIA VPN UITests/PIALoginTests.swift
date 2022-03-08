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

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func assertfalse(with message: String) {
        XCTAssert(false, message)
    }
    
    
    func testInvalidUserLogin() throws {
        
        var isNewButtonUsed = false
        
        // wait for feature flags
        var submitButtonExists = app.buttons[Accessibility.UITests.Login.submit].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        
        // check if new button should be used
        if !submitButtonExists {
            submitButtonExists = app.buttons[Accessibility.UITests.Login.submitNew].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
            isNewButtonUsed = true
        }
        
        app.switchEnvironmentToStaging()
        
        if submitButtonExists {
            if submitButtonExists && !isNewButtonUsed {
                app.buttons[Accessibility.UITests.Login.submit].tap()
            } else {
                app.buttons[Accessibility.UITests.Login.submitNew].tap()
            }
            
            let usernameTextField = app.textFields[Accessibility.UITests.Login.username]
            let passwordTextField = app.secureTextFields[Accessibility.UITests.Login.password]
            let loginButton = app.buttons[Accessibility.UITests.Login.submit]
            
            if usernameTextField.exists && passwordTextField.exists {
                // Type username
                usernameTextField.tap()
                app.typeString(with: "randomusername")
                
                // Type password
                passwordTextField.tap()
                app.typeString(with: "randompassword")
                
                let expectation = XCTestExpectation(description: "Perform login")
                loginButton.tap()
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(5)) {
                    XCTAssert(loginButton.exists, "testInvalideUserLogin failed")
                    expectation.fulfill()
                }
                wait(for: [expectation], timeout: PIALoginTests.timeoutUIOps)
            } else {
                assertfalse(with: "Username and Password text fields did not exist or are moved")
            }
        } else {
            assertfalse(with: "Login button did not exist or is moved")
        }
    }
    
    func testActiveUserLogin() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testInactiveUserLogin() throws {
        
    }
}

private extension XCUIApplication {
    func typeString(with text: String) {
        // Issue with custome fields:
        // https://stackoverflow.com/questions/32184837/ui-testing-failure-neither-element-nor-any-descendant-has-keyboard-focus-on-se
        for str in Array(text) {
            self.keys[String(str)].tap()
        }
    }
    
    func switchEnvironmentToStaging() {
        if Client.environment == .production {
            // wait until the button is available
            _ = self.buttons[Accessibility.UITests.Welcome.environment].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
            
            // then click it to switch environment
            self.buttons[Accessibility.UITests.Welcome.environment].tap()
        }
    }
}
