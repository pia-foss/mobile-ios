//
//  DedicatedIPScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var dedicatedIPTitleString: String {getString(key: "dedicated.ip.title", comment: "Enter Your Dedicated IP Token")}
    var dedicatedIPHeader: XCUIElement {staticText(with: dedicatedIPTitleString)}
    var dedicatedIPTextFieldString: String {getString(key: "dedicated.ip.token.textfield.accessibility", comment: "The textfield to type the Dedicated IP token")}
    var dedicatedIPTextField: XCUIElement {textField(with: dedicatedIPTextFieldString)}
    var dedicatedIPList: XCUIElement {cell(with: "DedicatedIpRowViewCell")}
    var invalidTokenErrorString: String {getString(key: "dedicated.ip.message.invalid.token", comment: "Your token is invalid. Please make sure you have entered the token correctly.")}
    var invalidTokenErrorMessage: XCUIElement {staticText(with: invalidTokenErrorString)}
    var emptyTokenErrorString: String {getString(key: "dedicated.ip.message.incorrect.token", comment: "Please make sure you have entered the token correctly")}
    var emptyTokenErrorMessage: XCUIElement {staticText(with: emptyTokenErrorString)}
    var deleteTokenButton: XCUIElement {button(with: "Delete")}
    var confirmDeleteButton: XCUIElement {staticText(with: "OK")}
    
    func navigateToDedicatedIPScreen() {
        selectSideMenu(menuName: "Dedicated IP")
        XCTAssert(dedicatedIPHeader.waitForElementToAppear())
    }
    
    func activateDedicatedIP (with dedicatedIP:DedicatedIP) {
        dedicatedIPTextField.waitForElementToAppear()
        dedicatedIPTextField.tap()
        dedicatedIPTextField.typeText(dedicatedIP.token)
        button(with:"Activate").tap()
    }
    
    func deleteDedicatedIP() {
        dedicatedIPList.waitForElementToAppear()
        let pressDuration: TimeInterval = 1.0
        let sourceCoordinate = dedicatedIPList.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let leftmostCoordinate = coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        sourceCoordinate.press(forDuration: pressDuration, thenDragTo: leftmostCoordinate)
        
        confirmDeleteButton.tap()
        XCTAssert(dedicatedIPTextField.waitForElementToAppear())
    }
}
