//
//  QuickSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 15/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var vpnKillSwitchQuickSettings: XCUIElement {
        cells.containing(.staticText, identifier: "VPN Kill Switch").firstMatch.switches.firstMatch
    }
    
    var networkManagementQuickSettings: XCUIElement {
        cells.containing(.staticText, identifier: "Network Management").firstMatch.switches.firstMatch
    }
    
    var privateBrowserQuickSettings: XCUIElement {
        cells.containing(.staticText, identifier: "Private Browser").firstMatch.switches.firstMatch
    }
    
    func enableVPNKillSwitchQuickSetting() {
        if(vpnKillSwitchQuickSettings.value as! String == "0"){
            vpnKillSwitchQuickSettings.tap()
        }
    }
    
    func disableVPNKillSwitchQuickSetting() {
        if(vpnKillSwitchQuickSettings.value as! String == "1"){
            vpnKillSwitchQuickSettings.tap()
        }
    }
    
    func enableNetworkManagementQuickSetting() {
        if(networkManagementQuickSettings.value as! String == "0"){
            networkManagementQuickSettings.tap()
        }
    }
    
    func disableNetworkManagementQuickSetting() {
        if(networkManagementQuickSettings.value as! String == "1"){
            networkManagementQuickSettings.tap()
        }
    }
    
    func enablePrivateBrowserQuickSetting() {
        if(privateBrowserQuickSettings.value as! String == "0"){
            privateBrowserQuickSettings.tap()
        }
    }
    
    func disablePrivateBrowserQuickSetting() {
        if(privateBrowserQuickSettings.value as! String == "1"){
            privateBrowserQuickSettings.tap()
        }
    }
}