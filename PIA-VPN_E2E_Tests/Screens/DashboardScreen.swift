//
//  DashboardScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import PIAAccessibility
import XCTest

extension XCUIApplication {
    var dashboardMenuButton: XCUIElement { button(with: AccessibilityID.Dashboard.menu) }
    var editString: String { getString(key: "menu.accessibility.edit.tile", comment: "Edit") }
    var dashboardEditButton: XCUIElement { button(with: editString) }
    var connectionButton: XCUIElement { button(with: AccessibilityID.Dashboard.connectionButton) }
    var connectedStatusString: String { getString(key: "dashboard.accessibility.vpn.button.isOn", comment: "VPN Connection button. The VPN is currently connected") }
    var connectedStatusLabel: XCUIElement { button(with: connectedStatusString) }
    var disconnectedStatusString: String { getString(key: "dashboard.accessibility.vpn.button.isOff", comment: "VPN Connection button. The VPN is currently disconnected") }
    var disconnectedStatusLabel: XCUIElement { button(with: disconnectedStatusString) }
    var confirmationDialogButton: XCUIElement { button(with: AccessibilityID.Dialog.destructive).firstMatch }
    var quickSettingsButton: XCUIElement { cell(with: AccessibilityID.Tiles.quickSettingsCell) }
    var privateBrowserButtonString: String { getString(key: "tiles.quicksetting.private.browser.title", comment: "Private Browser") }
    var privateBrowserButton: XCUIElement { button(with: privateBrowserButtonString) }
    var enableString: String { getString(key: "global.enable", comment: "Enable") }
    var disableString: String { getString(key: "global.disable", comment: "Disable") }
    var automationTileString: String { getString(key: "tiles.quicksetting.automation.title", comment: "Automation") }
    var enableAutomationButton: XCUIElement { button(with: "\(enableString) \(automationTileString)") }
    var disableAutomationButton: XCUIElement { button(with: "\(disableString) \(automationTileString)") }
    var enableVPNKillSwitchButton: XCUIElement { button(with: "\(enableString) \(vpnKillSwitchString)") }
    var disableVPNKillSwitchButton: XCUIElement { button(with: "\(disableString) \(vpnKillSwitchString)") }
    var killSwitchAlertCloseButton: XCUIElement { alerts.buttons[getString(key: "global.close", comment: "Close")].firstMatch }
    var killSwitchAlertEnableButton: XCUIElement { alerts.buttons[enableString].firstMatch }
    var disableKillSwitchConfirmButton: XCUIElement { alerts.buttons[disableString].firstMatch }
    var disableKillSwitchCancelButton: XCUIElement { alerts.buttons[getString(key: "global.cancel", comment: "Cancel")].firstMatch }
    var reconnectAlertLaterButton: XCUIElement { alerts.buttons[getString(key: "settings.commit.buttons.later", comment: "Later")] }
    var regionTileCollectionViewCell: XCUIElement { cell(with: AccessibilityID.Tiles.regionCell) }
    var publicIPValue: XCUIElement { staticText(with: AccessibilityID.Tiles.publicIP) }
    var vpnIPValue: XCUIElement { staticText(with: AccessibilityID.Tiles.vpnIP) }

    /// The public IP the IP tile shows, failing the test if it doesn't show one.
    func publicIPAddress(file: StaticString = #filePath, line: UInt = #line) -> String {
        XCTAssertTrue(scrollToElement(ipTileCollectionViewCell), "IP tile not found", file: file, line: line)
        let address = publicIPValue.waitForLabel(matching: ipv4Pattern)
        XCTAssertNotNil(address, "IP tile shows no public IP", file: file, line: line)
        return address ?? ""
    }

    /// Checks the connection really goes through the VPN: the IP tile shows a VPN IP, different from the public IP
    /// before connecting. Returns the VPN IP.
    @discardableResult
    func assertConnectedThroughVPN(
        publicIPBeforeConnecting: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        XCTAssertTrue(scrollToElement(ipTileCollectionViewCell), "IP tile not found", file: file, line: line)
        let vpnAddress = vpnIPValue.waitForLabel(matching: ipv4Pattern, timeout: vpnConnectionTimeout)
        XCTAssertNotNil(vpnAddress, "IP tile shows no VPN IP while connected", file: file, line: line)
        XCTAssertNotEqual(vpnAddress, publicIPBeforeConnecting, "VPN IP is the public IP", file: file, line: line)
        return vpnAddress ?? ""
    }

    func logOut() {
        guard dashboardMenuButton.waitForElementToAppear() else {
            XCTAssertTrue(waitForSignedOutScreen(), "Neither the dashboard nor a signed-out screen is showing")
            return
        }

        dashboardMenuButton.tap()
        XCTAssertTrue(logOutButton.waitForElementToAppear(), "Log out button not found")
        logOutButton.tap()
        XCTAssertTrue(confirmationDialogButton.waitForElementToAppear(), "Confirmation dialog button not found")
        confirmationDialogButton.tap()
        XCTAssertTrue(waitForSignedOutScreen())
    }

    func navigateToHome(using backToHomeButton: XCUIElement) {
        XCTAssertTrue(backToHomeButton.waitForElementToAppear(), "Back to home button not found")
        backToHomeButton.tap()
        XCTAssertTrue(connectionButton.waitForElementToAppear())
    }

    func enableVPNKillSwitchOnHome() {
        setQuickSetting(enabled: true, enableButton: enableVPNKillSwitchButton, disableButton: disableVPNKillSwitchButton)
    }

    func disableVPNKillSwitchOnHome() {
        setQuickSetting(enabled: false, enableButton: enableVPNKillSwitchButton, disableButton: disableVPNKillSwitchButton)
    }

    func enableAutomationOnHome() {
        setQuickSetting(enabled: true, enableButton: enableAutomationButton, disableButton: disableAutomationButton)
    }

    func disableAutomationOnHome() {
        setQuickSetting(enabled: false, enableButton: enableAutomationButton, disableButton: disableAutomationButton)
    }

    /// Taps the Quick Settings tile button unless the setting is already in the requested state. Automation needs the
    /// kill switch, so the dashboard asks before turning Automation on without it, or the kill switch off under it; the
    /// alert is accepted here, since the caller asked for the change.
    private func setQuickSetting(enabled: Bool, enableButton: XCUIElement, disableButton: XCUIElement) {
        XCTAssertTrue(scrollToElement(quickSettingsButton), "Quick Settings tile not found")
        XCTAssertTrue(enableButton.waitForElementToAppear() || disableButton.exists)
        if (enabled ? disableButton : enableButton).exists {
            return
        }
        (enabled ? enableButton : disableButton).tap()
        let acceptButton = enabled ? killSwitchAlertEnableButton : disableKillSwitchConfirmButton
        if acceptButton.waitForExistence(timeout: 2) {
            acceptButton.tap()
        }
        XCTAssertTrue((enabled ? disableButton : enableButton).waitForElementToAppear())
    }

    func connectToVPN() {
        if (connectedStatusLabel.waitForElementToAppear()) {
            return
        }
        connectionButton.tap()
        XCTAssertTrue(connectedStatusLabel.waitForElementToAppear(timeout: vpnConnectionTimeout))
    }

    func disconnectToVPN() {
        if (disconnectedStatusLabel.waitForElementToAppear()) {
            return
        }
        connectionButton.tap()
        XCTAssertTrue(disconnectedStatusLabel.waitForElementToAppear(timeout: vpnConnectionTimeout))
    }
}
