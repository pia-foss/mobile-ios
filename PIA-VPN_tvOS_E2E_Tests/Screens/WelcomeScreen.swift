//
//  WelcomeScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var signinImage: XCUIElement {image(with: "signin-world")}
    var loginButtonString: String {getString(key: "tvos.welcome.button.login", comment: "Log In")}
    var loginButton: XCUIElement {button(with: loginButtonString)}
    var signUpButtonString: String {getString(key: "tvos.welcome.button.signup", comment: "Sign Up")}
    var signUpButton: XCUIElement {button(with: signUpButtonString)}
    
    func navigateToSignInScreen(){
        signinImage.waitForElementToAppear()
        XCTAssert(loginButton.waitForElementToAppear())
        
        moveFocus(to: loginButton)
        XCUIRemote.shared.press(.select)
        XCTAssert(loginViaUsernameButton.waitForElementToAppear())
    }
    
    func navigateToSignUpScreen(){
        signinImage.waitForElementToAppear()
        XCTAssert(signUpButton.waitForElementToAppear())
        
        moveFocus(to: signUpButton)
        XCUIRemote.shared.press(.select)
        XCTAssert(signupImage.waitForElementToAppear())
    }
}
