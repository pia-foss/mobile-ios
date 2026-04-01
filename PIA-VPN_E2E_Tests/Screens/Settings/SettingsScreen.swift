//
//  SettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 1/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var generalTitleString: String {getString(key: "settings.section.general", comment: "General")}
    var generalSettingsButton: XCUIElement {staticText(with: generalTitleString)}
    var protocolsTitleString: String {getString(key: "settings.section.protocols", comment: "Protocols")}
    var protocolsSettingsButton: XCUIElement {staticText(with: protocolsTitleString)}
    var privacyFeaturesString: String {getString(key: "settings.section.privacyFeatures", comment: "Privacy Features")}
    var privacySettingsButton: XCUIElement {staticText(with: privacyFeaturesString)}
    var automationTitleString: String {getString(key: "settings.section.automation", comment: "Automation")}
    var automationSettingsButton: XCUIElement {staticText(with: automationTitleString)}
    var helpTitleString: String {getString(key: "settings.section.help", comment: "Help")}
    var helpSettingsButton: XCUIElement {staticText(with: helpTitleString)}
    var developmentSettingsButton: XCUIElement {staticText(with: "Development")}
    var closeButton: XCUIElement {button(with: "Close")}
    var settingsBackButton: XCUIElement {button(with: settingsButtonString)}
    var settingsHeader: XCUIElement {staticText(with: settingsButtonString)}
    
    func navigateToSettings() {
        selectSideMenu(menuName: settingsButtonString)
        XCTAssertTrue(settingsHeader.waitForElementToAppear())
    }
    
    func navigateToHomeFromSettings() {
        settingsBackButton.waitForElementToAppear()
        settingsBackButton.tap()
        navigateToHome(using: closeButton)
        XCTAssertTrue(connectionButton.waitForElementToAppear())
    }
}
