//
//  AutomationSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var automationHeader: XCUIElement{
        staticText(with: "Automation")
    }

    var enableAutomationSwitch: XCUIElement{
        switches(with: "Enable Automation")
    }
    
    func navigateToAutomationSettings() {
        navigateToSettings()
        automationSettingsButton.waitForElementToAppear()
        automationSettingsButton.tap()
        XCTAssert(automationHeader.waitForElementToAppear())
    }
}
