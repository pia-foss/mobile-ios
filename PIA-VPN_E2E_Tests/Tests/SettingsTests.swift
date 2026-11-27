//
//  SettingsTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 1/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

class SettingsTests: BaseTest {
    private let geoLocatedRegionDefaultValue = "1"
    private let vpnKillSwitchDefaultValue = "1"
    private let automationDefaultValue = "0"

    // MARK: - Updated settings for each category

    func testRevertsSettingsToDefaultsAfterLoggingOutAndBackIn() {
        // Update general settings
        app.navigateToGeneralSettings()
        app.disableGeoLocatedRegionSwitch()

        // This check is flaky in CI because the switch has a small animation and there is a small amount of delay when
        // the value gets updated after tapping the switch.
        // TODO: Enable this check when we disable the animations on E2E tests
        // XCTAssertNotEqual(app.geoLocatedRegionsSwitch.value as? String, geoLocatedRegionDefaultValue)

        // Update protocol settings
        app.navigateToHomeFromSettings()
        app.navigateToProtocolSettings()
        app.selectProtocol(protocolName: VPNProtocolName.openVPN)
        XCTAssertTrue(app.openVPN.waitForExistence(timeout: app.defaultTimeout))

        // Saving the protocol reinstalls the VPN profile, which iOS asks to allow.
        app.navigateToHomeFromSettings()
        app.allowVPNConfigurationIfPrompted()

        // Turn the kill switch off on the dashboard, then check Privacy Features shows it off.
        app.disableVPNKillSwitchOnHome()
        app.navigateToPrivacySettings()
        XCTAssertNotEqual(
            app.vpnKillSwitch.value as? String, vpnKillSwitchDefaultValue,
            "Privacy Features shows the kill switch on after turning it off on the dashboard")

        // Automation needs the kill switch, which is now off: turning it on asks to enable the kill switch, and Close
        // leaves it off.
        app.navigateToHomeFromSettings()
        app.navigateToAutomationSettings()
        app.enableAutomationSwitch.tapTrailingControl()
        XCTAssertTrue(app.killSwitchAlertCloseButton.waitForElementToAppear(), "No alert asking to enable the kill switch")
        app.killSwitchAlertCloseButton.tap()
        XCTAssertEqual(app.enableAutomationSwitch.value as? String, automationDefaultValue)

        app.navigateToHomeFromSettings()
        app.logOut()
        app.navigateToLoginScreen()
        app.logIn(with: Credentials.valid)
        app.acceptVPNPermission()

        // Expect the settings to be reverted to their default values
        app.navigateToGeneralSettings()
        XCTAssertEqual(app.geoLocatedRegionsSwitch.value as? String, geoLocatedRegionDefaultValue)

        app.navigateToHomeFromSettings()
        app.navigateToProtocolSettings()
        XCTAssertTrue(app.automaticProtocol.waitForExistence(timeout: app.defaultTimeout))

        app.navigateToHomeFromSettings()
        app.navigateToPrivacySettings()
        XCTAssertEqual(app.vpnKillSwitch.value as? String, vpnKillSwitchDefaultValue)

        app.navigateToHomeFromSettings()
        app.navigateToAutomationSettings()
        XCTAssertEqual(app.enableAutomationSwitch.value as? String, automationDefaultValue)
    }

    // MARK: - Automation requires the kill switch

    func testPrivacyFeaturesConfirmsTurningOffKillSwitchUnderAutomation() {
        // Changing the kill switch while connected asks to reconnect on closing Settings.
        app.disconnectToVPN()
        app.enableVPNKillSwitchOnHome()
        app.enableAutomationOnHome()
        app.navigateToPrivacySettings()

        // Cancel leaves the kill switch on.
        app.vpnKillSwitch.tapTrailingControl()
        XCTAssertTrue(app.disableKillSwitchCancelButton.waitForElementToAppear(), "No confirmation before turning off the kill switch")
        app.disableKillSwitchCancelButton.tap()
        XCTAssertTrue(app.vpnKillSwitch.waitForValue("1"), "Kill switch turned off although the change was cancelled")

        // Disable turns the kill switch off, and Automation with it.
        app.vpnKillSwitch.tapTrailingControl()
        XCTAssertTrue(app.disableKillSwitchConfirmButton.waitForElementToAppear(), "No confirmation before turning off the kill switch")
        app.disableKillSwitchConfirmButton.tap()
        XCTAssertTrue(app.vpnKillSwitch.waitForValue("0"), "Kill switch still on after confirming")

        app.navigateToHomeFromSettings()
        XCTAssertTrue(app.scrollToElement(app.quickSettingsButton), "Quick Settings tile not found")
        XCTAssertTrue(app.enableVPNKillSwitchButton.waitForElementToAppear(), "Kill switch still on")
        XCTAssertTrue(app.enableAutomationButton.exists, "Automation still on with the kill switch off")
    }

    func testAutomationSettingsAsksToEnableKillSwitch() {
        app.disconnectToVPN()
        app.disableAutomationOnHome()
        app.disableVPNKillSwitchOnHome()
        app.navigateToAutomationSettings()

        // Close leaves Automation off.
        app.enableAutomationSwitch.tapTrailingControl()
        XCTAssertTrue(app.killSwitchAlertCloseButton.waitForElementToAppear(), "No alert asking to enable the kill switch")
        app.killSwitchAlertCloseButton.tap()
        XCTAssertTrue(app.enableAutomationSwitch.waitForValue("0"), "Automation turned on without the kill switch")

        // Enable turns both on.
        app.enableAutomationSwitch.tapTrailingControl()
        XCTAssertTrue(app.killSwitchAlertEnableButton.waitForElementToAppear(), "No alert asking to enable the kill switch")
        app.killSwitchAlertEnableButton.tap()
        XCTAssertTrue(app.enableAutomationSwitch.waitForValue("1"), "Automation still off after enabling the kill switch")

        app.navigateToHomeFromSettings()
        XCTAssertTrue(app.scrollToElement(app.quickSettingsButton), "Quick Settings tile not found")
        XCTAssertTrue(app.disableVPNKillSwitchButton.waitForElementToAppear(), "Kill switch still off")
        XCTAssertTrue(app.disableAutomationButton.exists, "Automation still off")
    }

    // MARK: - Help settings interaction

    func testShowsDebugReportReviewWhenSendingDebugLog() {
        app.navigateToHelpSettings()
        app.sendDebugButton.tap()

        XCTAssertTrue(app.debugReportReviewSendButton.waitForExistence(timeout: app.defaultTimeout))
        XCTAssertTrue(app.debugReportReviewShareButton.exists)
    }

    func testConfirmsDebugInformationSubmitted() throws {
        app.navigateToDebugReportReview()
        app.debugReportReviewSendButton.tap()
        XCTAssertTrue(app.successfulSendDebugMessage.waitForExistence(timeout: app.defaultTimeout))
    }

    func testLatestNewsShowsTryWireGuard() {
        app.navigateToHelpSettings()
        app.latestNewsButton.tap()
        XCTAssertTrue(app.tryWireguardNowButton.waitForExistence(timeout: app.defaultTimeout))

        app.tryWireguardNowButton.tap()
        XCTAssertTrue(app.protocolsSettingsButton.waitForExistence(timeout: app.defaultTimeout))
        XCTAssertTrue(app.wireguard.waitForExistence(timeout: app.defaultTimeout))
    }

    func testHelpImprovePIAShowsConnectionStats() {
        app.navigateToHelpSettings()
        app.enableHelpImprovePIA()
        XCTAssertTrue(app.connectionStatsButton.waitForExistence(timeout: app.defaultTimeout))
    }

    func testDisplaysVersionNumber() {
        app.navigateToHelpSettings()
        XCTAssertTrue(app.versionNo.waitForExistence(timeout: app.defaultTimeout))
    }
}
