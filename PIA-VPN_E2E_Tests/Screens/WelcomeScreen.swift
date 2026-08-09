//
//  WelcomeScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    /// The signup paywall's Log In button. It keeps the historical `id.login.submit` identifier so
    /// this path survived the paywall rewrite.
    ///
    /// The previous implementation also looked for a `submitNew` identifier that was never declared
    /// anywhere, so this file did not compile.
    var welcomeLoginButton: XCUIElement { button(with: PIALibraryAccessibility.Id.Login.submit) }

    func navigateToLoginScreen() {
        XCTAssertTrue(welcomeLoginButton.waitForElementToAppear())
        welcomeLoginButton.tap()
        XCTAssertTrue(loginButton.waitForElementToAppear())
    }
}
