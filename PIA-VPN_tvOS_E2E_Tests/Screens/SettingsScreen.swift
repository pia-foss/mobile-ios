//
//  SettingsScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var settingsTitleString: String {getString(key: "menu.item.settings", comment: "Settings")}
    var settingsTitle: XCUIElement {staticText(with: settingsTitleString)}
    var accountTitleString: String {getString(key: "menu.item.account", comment: "Account")}
    var accountButton: XCUIElement {button(with: accountTitleString)}
    var accountTitle: XCUIElement {staticText(with: accountTitleString)}
    var dedicatedIPButtonString: String {getString(key: "dedicated.ip.title", comment: "Dedicated IP")}
    var dedicatedIPButton: XCUIElement {button(with: dedicatedIPButtonString)}
    var enterDedicatedIPButtonString: String {getString(key: "settings.dedicatedip.title1", comment: "Enter Dedicated IP")}
    var enterDedicatedIPTitle: XCUIElement {staticText(with: enterDedicatedIPButtonString)}
    var logoutButtonString: String {getString(key: "settings.account.log_out_button.title", comment: "Log Out")}
    var logoutButton: XCUIElement {button(with: logoutButtonString)}
    var logoutAlertButtonString: String {getString(key: "settings.account.log_out_alert.title", comment: "Are you sure?")}
    var logoutAlertButton: XCUIElement {alert(with: logoutAlertButtonString).buttons[logoutButtonString].firstMatch}
    
    func navigateToAccountSettingsScreen(){
        accountButton.waitForElementToAppear()
        moveFocus(to: accountButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
        XCTAssert(accountTitle.waitForElementToAppear())
    }
    
    func navigateToDedicatedIPScreen(){
        dedicatedIPButton.waitForElementToAppear()
        moveFocus(to: dedicatedIPButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
        XCTAssert(enterDedicatedIPTitle.waitForElementToAppear()||deleteDedicatedIPButton.waitForElementToAppear())
    }
}
