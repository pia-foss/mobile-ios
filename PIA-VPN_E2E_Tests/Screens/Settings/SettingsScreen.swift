//
//  SettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 1/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var generalSettingsButton: XCUIElement {
        staticText(with: "General")
    }
    
    var protocolsSettingsButton: XCUIElement {
        staticText(with: "Protocols")
    }
    
    var privacySettingsButton: XCUIElement {
        staticText(with: "Privacy Features")
    }
    
    var automationSettingsButton: XCUIElement {
        staticText(with: "Automation")
    }
    
    var helpSettingsButton: XCUIElement {
        staticText(with: "Help")
    }
    
    var developmentSettingsButton: XCUIElement {
        staticText(with: "Development")
    }
    
    var closeButton: XCUIElement {
        button(with: "Close")
    }
    
    var settingsBackButton: XCUIElement {
        button(with: "Settings")
    }
    
    func navigateToSettings() {
        guard dashboardMenuButton.waitForExistence(timeout: defaultTimeout) else { return }
        dashboardMenuButton.tap()
        
        if settingsButton.waitForExistence(timeout: defaultTimeout) {
            settingsButton.tap()
        }
    }
    
    func navigateToHomeFromSettings() {
        if settingsBackButton.waitForExistence(timeout: defaultTimeout) {
            settingsBackButton.tap()
            navigateToHome(using: closeButton)
        }
    }
}
