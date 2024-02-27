//
//  SettingsScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var accountButton:XCUIElement {button(with: "Account")}
    var accountTitle:XCUIElement {staticText(with: "Account")}
    var dedicatedIPButton:XCUIElement {button(with: "Dedicated IP")}
    var dedicatedIPTitle:XCUIElement {staticText(with: "Dedicated IP")}
    var logoutButton:XCUIElement {button(with: "Log Out")}
    var logoutAlertButton:XCUIElement {alert(with: "Are you sure?").buttons["Log Out"].firstMatch}
    
    func navigateToAccountSettings(){
        guard accountButton.waitForExistence(timeout: defaultTimeout) else {return}
        moveFocus(to: accountButton)
        XCUIRemote.shared.press(.select)
        guard accountTitle.waitForExistence(timeout: defaultTimeout) else {return}
    }
    

}
