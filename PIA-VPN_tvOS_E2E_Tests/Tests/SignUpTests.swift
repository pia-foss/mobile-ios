//
//  SignUpTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 20/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class SignUpTests: BaseTest {
    override class var shouldLogIn: Bool { false }

    // MARK: - Navigating to the sign up page

    func testShowsPlanSelection() {
        app.logout()
        app.navigateToSignUpScreen()
        XCTAssertTrue(app.yearlyPlanButton.waitForElementToAppear())
        XCTAssertTrue(app.monthlyPlanButton.waitForElementToAppear())
    }

    // MARK: - Footer navigation

    func testFooterNavigatesToPrivacyPolicyAndTermsOfService() {
        app.logout()
        app.navigateToSignUpScreen()
        app.navigateToPrivacyPolicyScreen()
        XCTAssertTrue(app.privacyPolicyTitle.waitForElementToAppear())
        app.navigateBackToSignUp()
        app.navigateToTermsOfService()
        XCTAssertTrue(app.termsAndConditionsTitle.waitForElementToAppear())
    }
}
