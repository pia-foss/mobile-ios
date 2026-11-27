//
//  SideMenuTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 9/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class SideMenuTests: BaseTest {
    // MARK: - Selecting a side menu item

    func testSideMenuItemsNavigateToTheirScreens() {
        if app.closeButton.exists {
            app.navigateToHome(using: app.closeButton)
        }
        app.selectSideMenu(menuName: "Region selection")
        XCTAssertTrue(app.regionSelectionHeader.waitForExistence(timeout: app.defaultTimeout))

        app.navigateToHome(using: app.closeButton)
        app.selectSideMenu(menuName: "Account")
        XCTAssertTrue(app.staticText(with: "Account").waitForExistence(timeout: app.defaultTimeout))

        app.navigateToHome(using: app.closeButton)
        app.selectSideMenu(menuName: "About")
        XCTAssertTrue(app.staticText(with: "About").waitForExistence(timeout: app.defaultTimeout))
    }
}
