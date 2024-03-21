//
//  GeneralSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var generalHeader: XCUIElement{
        staticText(with: "General")
    }
    
    var connectSiriButton: XCUIElement {
        staticText(with: "'Connect' Siri Shortcut")
    }
    
    var disconnectSiriButton: XCUIElement {
        staticText(with: "'Disconnect' Siri Shortcut")
    }
    
    var serviceCommMessageSwitch: XCUIElement {
        switches(with: "Show Service Communication Messages")
    }
    
    var geoLocatedRegionsSwitch: XCUIElement {
        switches(with: "Show Geo-located Regions")
    }
    
    var resetSettingsButton: XCUIElement {
        staticText(with: "Reset settings to default")
    }
    
    func navigateToGeneralSettings() {
        navigateToSettings()
        generalSettingsButton.waitForElementToAppear()
        generalSettingsButton.tap()
        XCTAssert(generalHeader.waitForElementToAppear())
    }
    
    func enableGeoLocatedRegionSwitch() {
        if ((geoLocatedRegionsSwitch.value as! String) == "1") {
            return
        }
        geoLocatedRegionsSwitch.tap()
    }
    
    func disableGeoLocatedRegionSwitch() {
        if ((geoLocatedRegionsSwitch.value as! String) == "0") {
            return
        }
        geoLocatedRegionsSwitch.tap()
    }
}
