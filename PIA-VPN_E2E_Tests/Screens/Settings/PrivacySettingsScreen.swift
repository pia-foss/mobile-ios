//
//  PrivacySettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var privacyHeader: XCUIElement{staticText(with: privacyFeaturesString)}
    var vpnKillSwitch: XCUIElement {switches(with: vpnKillSwitchString)}
    var safariContentBlockerTitleString: String {getString(key: "settings.content_blocker.title", comment: "Safari Content Blocker state")}
    var safariContentBlockerSwitch: XCUIElement {switches(with: safariContentBlockerTitleString)}
    var blockerRefreshTitleString: String {getString(key: "settings.content_blocker.refresh.title", comment: "Refresh block list")}
    var refreshBlockListButton: XCUIElement {staticText(with: blockerRefreshTitleString)}
    
    func navigateToPrivacySettings() {
        navigateToSettings()
        privacySettingsButton.waitForElementToAppear()
        privacySettingsButton.tap()
        XCTAssertTrue(privacyHeader.waitForElementToAppear())
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
