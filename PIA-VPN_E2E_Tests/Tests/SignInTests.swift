//
//  SignInTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

class SignInTests: BaseTest {
    // MARK: - Account validations

    func testSignsInWithValidCredentials() {
        app.logOut()
        app.navigateToLoginScreen()
        app.logIn(with: Credentials.valid)
        XCTAssertTrue(app.vpnPermissionScreen.waitForExistence(timeout: app.defaultTimeout))
    }

    func testShowsErrorForInvalidCredentials() {
        app.logOut()
        app.navigateToLoginScreen()
        app.logIn(with: Credentials.invalid)
        XCTAssertTrue(app.loginErrorMessage.waitForExistence(timeout: app.shortTimeout))
        XCTAssertFalse(app.vpnPermissionScreen.waitForExistence(timeout: app.defaultTimeout))
    }
}
