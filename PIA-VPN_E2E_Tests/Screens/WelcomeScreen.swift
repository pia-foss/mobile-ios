//
//  WelcomeScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import PIAAccessibility
import XCTest

extension XCUIApplication {
    /// The signup paywall's Log In button.
    var welcomeLoginButton: XCUIElement { button(with: AccessibilityID.Paywall.loginButton) }

    func navigateToLoginScreen() {
        dismissConsentScreenIfPresented()
        XCTAssertTrue(welcomeLoginButton.waitForElementToAppear())
        welcomeLoginButton.tap()
        XCTAssertTrue(loginButton.waitForElementToAppear())
    }
}
