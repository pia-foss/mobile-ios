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
    var helpButton:XCUIElement {button(with: "questionmark.circle")}
    var connectButton:XCUIElement {button(with: "connect-inner-button")}
    var piaVPNButton:XCUIElement {button(with: "PIA VPN")}
    var connectedStatus: XCUIElement {staticText(with: "Connected")}
    var notConnectedStatus: XCUIElement {staticText(with: "Not Connected")}
    var selectedLocationButton: XCUIElement {findElementWithPartialText(partialText: "Selected Location", elementType: .button)!}
    
    func navigateToSettingsScreen(){
        settingsButton.waitForElementToAppear()
        moveFocus(to: settingsButton, startingDirection: .up)
        XCUIRemote.shared.press(.select)
        XCTAssert(settingsTitle.waitForElementToAppear())
    }
    
    func navigateToHelpScreen(){
        helpButton.waitForElementToAppear()
        moveFocus(to: helpButton, startingDirection: .up)
        XCUIRemote.shared.press(.select)
        XCTAssert(helpTitle.waitForElementToAppear())
    }
    
    func logout(){
        if(loginButton.waitForElementToAppear()){
            return;
        }
        
        if(settingsButton.waitForElementToAppear()){
            navigateToSettingsScreen()
            navigateToAccountSettingsScreen()
            XCTAssert(logoutButton.waitForElementToAppear())
            
            moveFocus(to: logoutButton)
            XCUIRemote.shared.press(.select)
            moveFocus(to: logoutAlertButton)
            XCUIRemote.shared.press(.select)
            XCTAssert(signinImage.waitForElementToAppear())
        }
    }
    
    func connect(){
        if (connectedStatus.exists) {
            return
        }
        
        if (notConnectedStatus.exists){
            moveFocus(to: connectButton)
            XCUIRemote.shared.press(.select)
            XCTAssert(connectedStatus.waitForElementToAppear())
        }
    }
    
    func disconnect(){
        if (notConnectedStatus.exists) {
            return
        }
        
        if (connectedStatus.exists){
            moveFocus(to: connectButton)
            XCUIRemote.shared.press(.select)
            XCTAssert(notConnectedStatus.waitForElementToAppear())
        }
    }
}

