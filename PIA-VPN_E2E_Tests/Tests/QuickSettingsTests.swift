//
//  QuickSettingsTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 15/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

class QuickSettingsTests: BaseTest {
    override func setUpWithError() throws {
        try super.setUpWithError()

        // Changing these settings while connected asks to reconnect; start disconnected, closing any leftover prompt.
        if app.reconnectAlertLaterButton.waitForExistence(timeout: 2) {
            app.reconnectAlertLaterButton.tap()
        }
        app.disconnectToVPN()
    }

    // MARK: - Quick settings items displayed on home screen

    func testShowsEveryShortcut() {
        XCTAssertTrue(app.privateBrowserButton.waitForExistence(timeout: app.defaultTimeout))
        XCTAssertTrue(
            app.enableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)
                || app.disableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)
        )
        XCTAssertTrue(
            app.enableAutomationButton.waitForExistence(timeout: app.defaultTimeout)
                || app.disableAutomationButton.waitForExistence(timeout: app.defaultTimeout)
        )
    }

    func testIndicatesEnabledWhenUserEnablesShortcut() {
        app.enableVPNKillSwitchOnHome()
        XCTAssertTrue(app.disableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout))

        app.enableAutomationOnHome()
        XCTAssertTrue(app.disableAutomationButton.waitForExistence(timeout: app.defaultTimeout))
    }

    func testIndicatesDisabledWhenUserDisablesShortcut() {
        app.disableVPNKillSwitchOnHome()
        XCTAssertTrue(app.enableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout))

        app.enableVPNKillSwitchOnHome()
        app.disableAutomationOnHome()
        XCTAssertTrue(app.enableAutomationButton.waitForExistence(timeout: app.defaultTimeout))
    }

    /// Automation runs on the kill switch's on-demand rules, so it can never be on while the kill switch is off.
    func testAutomationRequiresKillSwitch() {
        app.disableAutomationOnHome()
        app.disableVPNKillSwitchOnHome()

        // Turning Automation on without the kill switch asks to enable it; Close leaves both off.
        app.enableAutomationButton.tap()
        XCTAssertTrue(app.killSwitchAlertCloseButton.waitForElementToAppear(), "No alert asking to enable the kill switch")
        app.killSwitchAlertCloseButton.tap()
        XCTAssertTrue(app.enableAutomationButton.waitForElementToAppear(), "Automation turned on without the kill switch")
        XCTAssertTrue(app.enableVPNKillSwitchButton.exists)

        // Enable turns both on.
        app.enableAutomationButton.tap()
        XCTAssertTrue(app.killSwitchAlertEnableButton.waitForElementToAppear(), "No alert asking to enable the kill switch")
        app.killSwitchAlertEnableButton.tap()
        XCTAssertTrue(app.disableAutomationButton.waitForElementToAppear())
        XCTAssertTrue(app.disableVPNKillSwitchButton.waitForElementToAppear())

        // Turning the kill switch off asks to confirm; Cancel leaves both on.
        app.disableVPNKillSwitchButton.tap()
        XCTAssertTrue(app.disableKillSwitchCancelButton.waitForElementToAppear(), "No confirmation before turning off the kill switch")
        app.disableKillSwitchCancelButton.tap()
        XCTAssertTrue(app.disableVPNKillSwitchButton.waitForElementToAppear())
        XCTAssertTrue(app.disableAutomationButton.exists, "Automation turned off when the kill switch change was cancelled")

        // Disable turns both off.
        app.disableVPNKillSwitchButton.tap()
        XCTAssertTrue(app.disableKillSwitchConfirmButton.waitForElementToAppear(), "No confirmation before turning off the kill switch")
        app.disableKillSwitchConfirmButton.tap()
        XCTAssertTrue(app.enableVPNKillSwitchButton.waitForElementToAppear())
        XCTAssertTrue(app.enableAutomationButton.waitForElementToAppear(), "Automation still on with the kill switch off")
    }
}
