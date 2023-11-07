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
    
    var helpImprovePIASwitch: XCUIElement {
        switches(with: "Help improve PIA")
    }
    
    var latestNewsButton: XCUIElement {
        staticText(with: "Latest News")
    }
    
    func navigateToHelpSettings() {
        guard dashboardMenuButton.exists else { return }
        dashboardMenuButton.tap()
        
        if settingsButton.waitForExistence(timeout: defaultTimeout) {
            settingsButton.tap()
        }
        
        if helpSettingsButton.waitForExistence(timeout: defaultTimeout) {
            automationSettingsButton.tap()
        }
    }
}
