//
//  WelcomeScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var welcomeLoginButton: XCUIElement {
      button(with: PIALibraryAccessibility.Id.Login.submitNew)
    }
    
    var welcomeLoginButtonOldVersion: XCUIElement {
      button(with: PIALibraryAccessibility.Id.Login.submit)
    }
    
    func navigateToLoginScreen() {
        if welcomeLoginButton.waitForExistence(timeout: shortTimeout) {
            welcomeLoginButton.tap()
        } else {
            if welcomeLoginButtonOldVersion.waitForExistence(timeout: shortTimeout) {
                welcomeLoginButtonOldVersion.tap()
                WaitHelper.waitForElementToBeVisible(loginButton, timeout: defaultTimeout,
                                                     onSuccess:{print("successful navigation to login screen")}, onFailure:{error in print("loginButton is not visible")})
            }
        }
    }
}
