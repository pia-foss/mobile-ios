//
//  DedicatedIPScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 28/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var dIPTokenTextField:XCUIElement {textField(with: "Enter Your Dedicated IP Token")}
    var activateButton: XCUIElement {button(with: "Activate")}
    var emptyTokenErrorMessage: XCUIElement {staticText(with: "Your token can't be empty.")}
    var invalidTokenErrorMessage: XCUIElement {staticText(with: "Your token is either invalid or has expired.")}
    var activeDIPMessage: XCUIElement {staticText(with: "Your Dedicated IP it's now active.")}
    var deleteDedicatedIPButton: XCUIElement {button(with: "Delete Dedicated IP")}
    var activeDIPStatus: XCUIElement {staticText(with: "Active")}
    var confirmDeleteButton: XCUIElement {button(with: "Yes, Delete")}
    
    func activateDIPToken(DIP: DedicatedIP){
    
        dIPTokenTextField.waitForElementToAppear()
        moveFocus(to: dIPTokenTextField)
        XCUIRemote.shared.press(.select)
        let navigator = KeyboardNavigator()
        navigator.resetKeyboardPosition()
        navigator.typeText(DIP.token, keyboardType: .multiRow)
        navigator.clickNext()
        activateButton.waitForElementToAppear()
        moveFocus(to: activateButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
        
        if(emptyTokenErrorMessage.exists || invalidTokenErrorMessage.exists) {
            return
        }
        
        else if(continueButton.exists) {
            moveFocus(to: continueButton.firstMatch)
            XCUIRemote.shared.press(.select)
        }
    }
    
    func deleteDedicatedIP(){
        deleteDedicatedIPButton.waitForElementToAppear()
        moveFocus(to: deleteDedicatedIPButton)
        XCUIRemote.shared.press(.select)
        confirmDeleteButton.waitForElementToAppear()
        moveFocus(to: confirmDeleteButton.firstMatch)
        XCUIRemote.shared.press(.select)
        XCTAssert(dIPTokenTextField.waitForElementToAppear())
    }
}
