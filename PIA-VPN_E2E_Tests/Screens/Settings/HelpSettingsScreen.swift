//
//  HelpSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var helpHeader:XCUIElement {
        staticText(with: "Help")
    }
    
    var sendDebugButton: XCUIElement {
        staticText(with: "Send Debug Log to support")
    }
    
    var successfulSendDebugMessage: XCUIElement {
        staticText(with: "Debug information submitted")
    }
    
    var helpImprovePIASwitch: XCUIElement {
        switches(with: "Help Improve PIA")
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
        navigateToSettings()
        helpSettingsButton.waitForElementToAppear()
        helpSettingsButton.tap()
        XCTAssert(helpHeader.waitForElementToAppear())
    }
    
    func enableHelpImprovePIA() {
        helpImprovePIASwitch.waitForElementToAppear()
        if (helpImprovePIASwitch.value as! String == "1") {
            return
        }
        helpImprovePIASwitch.tap()
    }
    
    func disableHelpImprovePIA() {
        helpImprovePIASwitch.waitForElementToAppear()
        if (helpImprovePIASwitch.value as! String == "0") {
            return
        }
        helpImprovePIASwitch.tap()
    }
}
