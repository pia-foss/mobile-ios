//
//  QuickSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 15/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var vpnKillSwitchString: String {getString(key: "settings.application_settings.kill_switch.title", comment: "VPN Kill Switch")}
    var vpnKillSwitchQuickSettings: XCUIElement {cells.containing(.staticText, identifier: vpnKillSwitchString).firstMatch.switches.firstMatch}
    var networkManagementString: String {getString(key: "tiles.quicksetting.nmt.title", comment: "Network Management")}
    var networkManagementQuickSettings: XCUIElement {cells.containing(.staticText, identifier: networkManagementString).firstMatch.switches.firstMatch}
    var privateBrowserString: String {getString(key: "tiles.quicksetting.private.browser.title", comment: "Private Browser")}
    var privateBrowserQuickSettings: XCUIElement {cells.containing(.staticText, identifier: privateBrowserString).firstMatch.switches.firstMatch}
    
    func navigateToQuickSettings() {
        guard quickSettingsButton.waitForExistence(timeout: defaultTimeout) else {return}
        quickSettingsButton.staticTexts["QUICK SETTINGS"].tap()
    }
    
    func enableVPNKillSwitchQuickSetting() {
        if(vpnKillSwitchQuickSettings.value as! String == "1"){
            return
        }
        vpnKillSwitchQuickSettings.tap()
    }
    
    func disableVPNKillSwitchQuickSetting() {
        if(vpnKillSwitchQuickSettings.value as! String == "0"){
            return
        }
        vpnKillSwitchQuickSettings.tap()
    }
    
    func enableNetworkManagementQuickSetting() {
        if(networkManagementQuickSettings.value as! String == "1"){
            return
        }
        networkManagementQuickSettings.tap()
    }
    
    func disableNetworkManagementQuickSetting() {
        if(networkManagementQuickSettings.value as! String == "0"){
            return
        }
        networkManagementQuickSettings.tap()
    }
    
    func enablePrivateBrowserQuickSetting() {
        if(privateBrowserQuickSettings.value as! String == "1"){
            return
        }
        privateBrowserQuickSettings.tap()
    }
    
    func disablePrivateBrowserQuickSetting() {
        if(privateBrowserQuickSettings.value as! String == "0"){
            return
        }
        privateBrowserQuickSettings.tap()
    }
}
