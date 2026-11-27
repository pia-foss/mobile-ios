//
//  HelpTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class HelpTests: BaseTest {
    // MARK: - Help screen

    func testShowsVersionAboutHelpImproveAndContactSupport() {
        app.navigateToHelpScreen()
        XCTAssertTrue(app.appVersion.waitForElementToAppear())
        XCTAssertTrue(app.aboutButton.waitForElementToAppear())
        XCTAssertTrue(app.helpImprovePIAButton.waitForElementToAppear())
        XCTAssertTrue(app.scanQRCodeContactUsMessage.waitForElementToAppear())
    }

    // MARK: - About screen

    func testShowsPrivacyPolicyAndItsQRCode() {
        app.navigateToHelpScreen()
        app.navigateToAboutScreen()
        app.navigateToPrivacyPolicyScreen()
        XCTAssertTrue(app.privacyPolicyMessage.waitForElementToAppear())
        XCTAssertTrue(app.scanQRCodePrivacyPolicyMessage.waitForElementToAppear())
    }

    func testShowsAcknowledgments() {
        app.navigateToHelpScreen()
        app.navigateToAboutScreen()
        app.navigateToAcknowledgmentsScreen()
        XCTAssertTrue(app.acknowledgementsMessage.waitForElementToAppear())
    }
}
