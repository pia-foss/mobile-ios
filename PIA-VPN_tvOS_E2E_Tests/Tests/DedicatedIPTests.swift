//
//  DedicatedIPTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 27/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class DedicatedIPTests: BaseTest {
    // MARK: - Activating dedicated IP tokens

    func testShowsErrorForInvalidToken() {
        openDedicatedIPScreenWithoutToken()
        app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .invalid))
        XCTAssertTrue(app.invalidTokenErrorMessage.waitForElementToAppear())
    }

    func testShowsErrorForEmptyToken() {
        openDedicatedIPScreenWithoutToken()
        app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .empty))
        XCTAssertTrue(app.emptyTokenErrorMessage.waitForElementToAppear())
    }

    func testActivatesValidToken() {
        openDedicatedIPScreenWithoutToken()
        app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .valid))
        XCTAssertTrue(app.activeDIPStatus.waitForElementToAppear())
    }

    // MARK: - Deleting dedicated IP

    func testDeletingRemovesDedicatedIPFromList() {
        app.navigateToSettingsScreen()
        app.navigateToDedicatedIPScreen()
        if !app.deleteDedicatedIPButton.exists {
            app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .valid))
        }
        app.deleteDedicatedIP()
        XCTAssertTrue(app.enterDedicatedIPTitle.waitForElementToAppear())
    }

    // MARK: - Helpers

    private func openDedicatedIPScreenWithoutToken() {
        app.navigateToSettingsScreen()
        app.navigateToDedicatedIPScreen()
        if app.deleteDedicatedIPButton.exists {
            app.deleteDedicatedIP()
        }
    }
}
