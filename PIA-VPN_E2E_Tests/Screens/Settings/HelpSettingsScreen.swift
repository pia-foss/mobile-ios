//
//  HelpSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var helpHeader: XCUIElement {staticText(with: helpTitleString)}
    var sendDebugButtonString: String {getString(key: "settings.application_information.debug.title", comment: "Send Debug Log to support")}
    var sendDebugButton: XCUIElement {staticText(with: sendDebugButtonString)}
    var successfulSendDebugMessageString: String {getString(key: "settings.application_information.debug.success.title", comment: "Debug information submitted")}
    var successfulSendDebugMessage: XCUIElement {staticText(with: successfulSendDebugMessageString)}
    var helpImprovePIAString: String {getString(key: "settings.service.quality.share.title", comment: "Help Improve PIA")}
    var helpImprovePIASwitch: XCUIElement {switches(with: helpImprovePIAString)}
    var connectionStatsButtonString: String {getString(key: "settings.service.quality.show.title", comment: "Connection stats")}
    var connectionStatsButton: XCUIElement {staticText(with: connectionStatsButtonString)}
    var latestNewsButtonString: String {getString(key: "settings.cards.history.title", comment: "Latest News")}
    var latestNewsButton: XCUIElement {staticText(with: latestNewsButtonString)}
    var versionNoString: String {getString(key: "global.version", comment: "Version")}
    var versionNo: XCUIElement {findElementWithPartialText(versionNoString)!}
    var tryWireguardNowButtonString: String {getString(key: "card.wireguard.cta.activate", comment: "Try WireGuard® now")}
    var tryWireguardNowButton: XCUIElement {findElementWithPartialText(tryWireguardNowButtonString)!}
    
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
