//
//  PrivacySettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var privacyHeader: XCUIElement{
        staticText(with: "Privacy Features")
    }
    
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
        navigateToSettings()
        privacySettingsButton.waitForElementToAppear()
        privacySettingsButton.tap()
        XCTAssert(privacyHeader.waitForElementToAppear())
    }
    
    func enableVPNKillSwitch(){
        if ((vpnKillSwitch.value as! String) == "1") {
            return
        }
        vpnKillSwitch.tap()
    }
    
    func disableVPNKillSwitch(){
        if ((vpnKillSwitch.value as! String) == "0") {
            return
        }
        vpnKillSwitch.tap()
        
        if(button(with: "CLOSE").exists) {
            button(with: "CLOSE").tap()
        }
    }
}
