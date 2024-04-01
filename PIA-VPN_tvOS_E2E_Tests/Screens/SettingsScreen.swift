//
//  SettingsScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var settingsTitle:XCUIElement {staticText(with: "Settings")}
    var accountButton:XCUIElement {button(with: "Account")}
    var accountTitle:XCUIElement {staticText(with: "Account")}
    var dedicatedIPButton:XCUIElement {button(with: "Dedicated IP")}
    var enterDedicatedIPTitle:XCUIElement {staticText(with: "Enter Dedicated IP")}
    var logoutButton:XCUIElement {button(with: "Log Out")}
    var logoutAlertButton:XCUIElement {alert(with: "Are you sure?").buttons["Log Out"].firstMatch}
    
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
