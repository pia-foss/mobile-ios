//
//  VPNPermissionScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import PIAAccessibility
import XCTest

extension XCUIApplication {
    // Any element type: the SwiftUI screen exposes its identifier on a ScrollView.
    var vpnPermissionScreen: XCUIElement { descendants(matching: .any)[AccessibilityID.VPNPermission.screen] }
    var vpnPermissionLabel: XCUIElement {
        staticText(with: getString(key: "vpn_permission.body.title", comment: "PIA needs access to your VPN profiles"))
    }
    var vpnPermissionButton: XCUIElement { button(with: AccessibilityID.VPNPermission.submit) }

    func acceptVPNPermission() {
        XCTAssertTrue(vpnPermissionLabel.waitForElementToAppear(), "VPN permission label not found")
        XCTAssertTrue(vpnPermissionButton.waitForElementToAppear(), "VPN permission button not found")
        dismissPromptsOverVPNPermission()
        vpnPermissionButton.tap()
        allowVPNConfigurationIfPrompted()
        XCTAssertTrue(connectionButton.waitForElementToAppear())
    }

    /// Clears the two iOS prompts that can land over the permission screen wherever their choice hasn't been made yet,
    /// such as a fresh Simulator: "Save Password?" (Not Now) and "Would Like to Send You Notifications" (Allow). Both
    /// arrive a few seconds after login at no fixed time, and a tap on OK underneath either sends the app to the home
    /// screen, so this watches for a fixed window. Buttons are matched by position, so it works in any device language.
    func dismissPromptsOverVPNPermission(window: TimeInterval = 6) {
        let savePasswordSheet = sheets.firstMatch
        let notificationsAlert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        let deadline = Date().addingTimeInterval(window)
        while Date() < deadline {
            if savePasswordSheet.exists {
                // Not Now is the leading button, Save the trailing one.
                savePasswordSheet.buttons.element(boundBy: 0).tap()
                XCTAssertTrue(savePasswordSheet.waitForElementToBeHidden(), "Save Password sheet still showing")
            } else if notificationsAlert.exists {
                // Don't Allow is the leading button, Allow the trailing one.
                notificationsAlert.buttons.element(boundBy: 1).tap()
                XCTAssertTrue(notificationsAlert.waitForElementToBeHidden(), "Notifications alert still showing")
            } else {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }

    /// Taps Allow on the system "Would Like to Add VPN Configurations" alert. iOS shows it whenever the VPN profile is
    /// missing, e.g. after logging out (which removes the profile); it isn't shown when the profile is still installed.
    /// The alert is matched by position, not label: iOS sometimes shows it in the device language instead of the app's.
    func allowVPNConfigurationIfPrompted() {
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        if alert.waitForExistence(timeout: shortTimeout) {
            // Allow is the leading button, Don't Allow the trailing one.
            alert.buttons.element(boundBy: 0).tap()
        }
    }
}
