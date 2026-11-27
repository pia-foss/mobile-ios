//
//  SignInTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class SignInTests: BaseTest {
    override class var shouldLogIn: Bool { false }

    // MARK: - Account validations

    func testSignsInWithValidCredentials() {
        app.logout()
        app.navigateToSignInScreen()
        app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
        XCTAssertTrue(app.helpImprovePIATitle.waitForElementToAppear())
    }

    func testShowsErrorForInvalidCredentials() {
        app.logout()
        app.navigateToSignInScreen()
        app.loginViaUsername(with: CredentialsUtil.credentials(type: .invalid))
        XCTAssertTrue(app.incorrectCredentialsErrorMessage.waitForElementToAppear())
    }
}
