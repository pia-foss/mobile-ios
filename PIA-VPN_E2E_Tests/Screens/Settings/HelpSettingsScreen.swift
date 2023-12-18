//
//  HelpSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var sendDebugButton: XCUIElement {
        staticText(with: "Send Debug Log to support")
    }
    
    var successfulSendDebugMessage: XCUIElement {
        staticText(with: "Debug information submitted")
    }
    
    var helpImprovePIASwitch: XCUIElement {
        switches(with: "Help improve PIA")
    }
    
    var connectionStatsButton: XCUIElement {
        staticText(with: "Connection stats")
    }
    
    var latestNewsButton: XCUIElement {
        staticText(with: "Latest News")
    }
    
    var versionNo: XCUIElement {
        findElementWithPartialText("Version")!
    }
    
    var tryWireguardNowButton: XCUIElement {
        findElementWithPartialText("Try WireGuard® now")!
    }
    
    func navigateToHelpSettings() {
        guard dashboardMenuButton.exists else { return }
        dashboardMenuButton.tap()
        
        if settingsButton.waitForExistence(timeout: defaultTimeout) {
            settingsButton.tap()
        }
        
        if helpSettingsButton.waitForExistence(timeout: defaultTimeout) {
            helpSettingsButton.tap()
        }
    }
    
    func enableHelpImprovePIA() {
        if (helpImprovePIASwitch.value as! String == "0") {
            helpImprovePIASwitch.tap()
        }
    }
    
    func disableHelpImprovePIA() {
        if (helpImprovePIASwitch.value as! String == "1") {
            helpImprovePIASwitch.tap()
        }
    }
}
