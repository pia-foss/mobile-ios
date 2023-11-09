//
//  AutomationSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var enableAutomationSwitch: XCUIElement{
        switches(with: "Enable Automation")
    }
    
    func navigateToAutomationSettings() {
        guard dashboardMenuButton.exists else { return }
        dashboardMenuButton.tap()
        
        if settingsButton.waitForExistence(timeout: defaultTimeout) {
            settingsButton.tap()
        }
        
        if automationSettingsButton.waitForExistence(timeout: defaultTimeout) {
            automationSettingsButton.tap()
        }
    }
}
