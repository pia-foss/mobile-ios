//
//  DashboardScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var settingsButton:XCUIElement {button(with: "gearshape")}
    var connectButton:XCUIElement {button(with: "connect-inner-button")}
    
    func navigateToSettingsScreen(){
        guard settingsButton.waitForExistence(timeout: defaultTimeout) else {return}
        moveFocus(to: settingsButton)
        XCUIRemote.shared.press(.select)
    }
    
    func logout(){
        if(settingsButton.waitForExistence(timeout: defaultTimeout)){
            navigateToSettingsScreen()
            navigateToAccountSettings()
            guard logoutButton.waitForExistence(timeout: defaultTimeout) else {return}
            moveFocus(to: logoutButton)
            XCUIRemote.shared.press(.select)
            moveFocus(to: logoutAlertButton)
            XCUIRemote.shared.press(.select)
        }
    }
}

