//
//  GeneralSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var generalHeader: XCUIElement{staticText(with: generalTitleString)}
    var connectSiriButtonString: String {getString(key: "siri.shortcuts.connect.row.title", comment: "'Connect' Siri Shortcut")}
    var connectSiriButton: XCUIElement {staticText(with: connectSiriButtonString)}
    var disconnectSiriButtonString: String {getString(key: "siri.shortcuts.disconnect.row.title", comment: "'Disconnect' Siri Shortcut")}
    var disconnectSiriButton: XCUIElement {staticText(with: disconnectSiriButtonString)}
    var serviceCommMessageString: String {getString(key: "inapp.messages.toggle.title", comment: "Show Service Communication Messages")}
    var serviceCommMessageSwitch: XCUIElement {switches(with: serviceCommMessageString)}
    var geoLocatedRegionsString: String {getString(key: "settings.geo.servers.description", comment: "Show Geo-located Regions")}
    var geoLocatedRegionsSwitch: XCUIElement {switches(with: geoLocatedRegionsString)}
    var resetSettingsString: String {getString(key: "settings.reset.defaults.title", comment: "Reset settings to default")}
    var resetSettingsButton: XCUIElement {staticText(with: resetSettingsString)}
    
    func navigateToGeneralSettings() {
        navigateToSettings()
        generalSettingsButton.waitForElementToAppear()
        generalSettingsButton.tap()
        XCTAssertTrue(generalHeader.waitForElementToAppear())
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
