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
    /// The Welcome Back screen's "Username and Password" button, shown instead of the paywall to returning users.
    var welcomeBackCredentialsButton: XCUIElement { button(with: AccessibilityID.WelcomeBack.credentialsButton) }

    /// Waits for the signed-out entry point: the Welcome Back screen for returning users, the paywall otherwise.
    func waitForSignedOutScreen() -> Bool {
        welcomeBackCredentialsButton.waitForElementToAppear() || welcomeLoginButton.exists
    }

    func navigateToLoginScreen() {
        dismissConsentScreenIfPresented()
        let entryButton =
            welcomeBackCredentialsButton.waitForElementToAppear(timeout: shortTimeout)
            ? welcomeBackCredentialsButton : welcomeLoginButton
        XCTAssertTrue(entryButton.waitForElementToAppear())
        entryButton.tap()
        XCTAssertTrue(loginButton.waitForElementToAppear())
    }
}
