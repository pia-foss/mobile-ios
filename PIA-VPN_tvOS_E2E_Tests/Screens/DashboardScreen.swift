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
    var piaVPNButton:XCUIElement {button(with: "PIA VPN")}
    
    func navigateToSettingsScreen(){
        settingsButton.waitForElementToAppear()
        moveFocus(to: settingsButton, startingDirection: .up)
        XCUIRemote.shared.press(.select)
        XCTAssert(settingsTitle.waitForElementToAppear())
    }
    
    func logout(){
        if(loginButton.waitForElementToAppear()){
            return;
        }
        
        if(settingsButton.waitForElementToAppear()){
            navigateToSettingsScreen()
            navigateToAccountSettings()
            XCTAssert(logoutButton.waitForElementToAppear())
            
            moveFocus(to: logoutButton)
            XCUIRemote.shared.press(.select)
            moveFocus(to: logoutAlertButton)
            XCUIRemote.shared.press(.select)
            XCTAssert(signinImage.waitForElementToAppear())
        }
    }
}

