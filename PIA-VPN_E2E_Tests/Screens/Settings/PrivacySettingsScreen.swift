//
//  PrivacySettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var vpnKillSwitch: XCUIElement {
        switches(with: "VPN Kill Switch")
    }
    
    var safariContentBlockerSwitch: XCUIElement {
        switches(with: "Safari Content Blocker state")
    }
    
    var refreshBlockListButton: XCUIElement {
        staticText(with: "Refresh block list")
    }
    
    func navigateToPrivacySettings() {
        guard dashboardMenuButton.exists else { return }
        dashboardMenuButton.tap()
        
        if settingsButton.waitForExistence(timeout: defaultTimeout) {
            settingsButton.tap()
        }
        
        if privacySettingsButton.waitForExistence(timeout: defaultTimeout) {
            privacySettingsButton.tap()
        }
    }
}