//
//  DedicatedIPScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 28/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var dIPTokenTextFieldString: String {getString(key: "settings.dedicatedip.placeholder", comment: "Enter Your Dedicated IP Token")}
    var dIPTokenTextField: XCUIElement {textField(with: dIPTokenTextFieldString)}
    var activateDIPButtonString: String {getString(key: "settings.dedicatedip.button", comment: "Activate")}
    var activateButton: XCUIElement {button(with: activateDIPButtonString)}
    var emptyTokenErrorString: String {getString(key: "settings.dedicatedip.alert.failure.message.empty", comment: "Your token can't be empty.")}
    var emptyTokenErrorMessage: XCUIElement {staticText(with: emptyTokenErrorString)}
    var invalidTokenErrorString: String {getString(key: "settings.dedicatedip.alert.failure.message", comment: "Your token is either invalid or has expired.")}
    var invalidTokenErrorMessage: XCUIElement {staticText(with: invalidTokenErrorString)}
    var activeDIPString: String {getString(key: "settings.dedicatedip.alert.success.message", comment: "Your Dedicated IP it's now active.")}
    var activeDIPMessage: XCUIElement {staticText(with: activeDIPString)}
    var deleteDIPButtonString: String {getString(key: "settings.dedicatedip.stats.delete.button", comment: "Delete Dedicated IP")}
    var deleteDedicatedIPButton: XCUIElement {button(with: deleteDIPButtonString)}
    var activeDIPStatusString: String {getString(key: "settings.dedicatedip.status.active", comment: "Active")}
    var activeDIPStatus: XCUIElement {staticText(with: activeDIPStatusString)}
    var confirmDeleteButtonString: String {getString(key: "settings.dedicatedip.stats.delete.alert.delete", comment: "Yes, Delete")}
    var confirmDeleteButton: XCUIElement {button(with: confirmDeleteButtonString)}
    
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
