//
//  OnboardingTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

class OnboardingTests: BaseTest {
    // MARK: - VPN profile installation permission

    func testShowsDashboardAfterAllowingVPNProfileInstallation() {
        app.logOut()
        app.navigateToLoginScreen()

        app.logIn(with: Credentials.valid)
        app.acceptVPNPermission()

        XCTAssertTrue(app.dashboardMenuButton.waitForExistence(timeout: app.defaultTimeout))
        XCTAssertFalse(app.vpnPermissionScreen.exists)
    }
}
