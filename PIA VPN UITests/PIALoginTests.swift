//
//  PIALoginTests.swift
//  PIA VPN UITests
//
//  Created by Waleed Mahmood on 01.03.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import XCTest

class PIALoginTests: XCTestCase {
    
    static let requestTimeout = 10
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func assertfalse(with message: String) {
        XCTAssert(false, message)
    }
    
    func testInvalideUserLogin() throws {
        let app = XCUIApplication()
        
        // wait for feature flags
        sleep(6)
        
        let loginButtonGetStartedView = app.buttons["uitests.login.submit"]
        let newLoginButtonGetStartedView = app.buttons["uitests.login.newSubmit"]
        
        if loginButtonGetStartedView.exists || newLoginButtonGetStartedView.exists {
            if loginButtonGetStartedView.exists {
                loginButtonGetStartedView.tap()
            } else {
                newLoginButtonGetStartedView.tap()
            }
            
            let usernameTextField = app.textFields["uitests.login.username"]
            let passwordTextField = app.secureTextFields["uitests.login.password"]
            let loginButton = app.buttons["uitests.login.submit"]
            
            if usernameTextField.exists && passwordTextField.exists {
                usernameTextField.tap()
                
                // Issue with custome fields:
                // https://stackoverflow.com/questions/32184837/ui-testing-failure-neither-element-nor-any-descendant-has-keyboard-focus-on-se
                
                // Type username
                for str in Array("randomusername") {
                    app.keys[String(str)].tap()
                }
                
                passwordTextField.tap()
                for str in Array("randompassword") {
                    app.keys[String(str)].tap()
                }
                
                let expectation = XCTestExpectation(description: "Perform login")
                loginButton.tap()
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(5)) {
                    XCTAssert(loginButton.exists, "testInvalideUserLogin failed")
                    expectation.fulfill()
                }
                wait(for: [expectation], timeout: TimeInterval(PIALoginTests.requestTimeout))
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
