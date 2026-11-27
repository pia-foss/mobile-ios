//
//  OnboardingTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 28/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class OnboardingTests: BaseTest {
    override class var shouldLogIn: Bool { false }

    // MARK: - VPN profile installation permission

    func testShowsHomeScreenAfterAllowingVPNProfileInstallation() {
        app.logout()
        app.navigateToSignInScreen()
        app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
        app.acceptSharingVPNStats()
        app.acceptVPNConfiguration()
        XCTAssertTrue(app.connectButton.waitForElementToAppear())
    }
}
