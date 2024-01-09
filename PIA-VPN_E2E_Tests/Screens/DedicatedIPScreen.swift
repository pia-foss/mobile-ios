//
//  DedicatedIPScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var dedicatedIPHeader: XCUIElement {
        staticText(with: "Dedicated IP")
    }
    
    var dedicatedIPTextField: XCUIElement {
        textField(with: "The textfield to type the Dedicated IP token")
    }
    
    var dedicatedIPList: XCUIElement {
        cell(with: "DedicatedIpRowViewCell")
    }
    
    var invalidTokenErrorMessage: XCUIElement {
        staticText(with: "Your token is invalid. Please make sure you have entered the token correctly.")
    }
    
    var emptyTokenErrorMessage: XCUIElement {
        staticText(with: "Please make sure you have entered the token correctly")
    }
    
    var deleteTokenButton: XCUIElement {
        button(with: "Delete")
    }
    
    var confirmDeleteButton: XCUIElement {
        staticText(with: "OK")
    }
    
    func navigateToDedicatedIPScreen() {
        guard dashboardMenuButton.waitForExistence(timeout: defaultTimeout) else {return}
        dashboardMenuButton.tap()
        
        if dedicatedIPButton.waitForExistence(timeout: defaultTimeout) {
            dedicatedIPButton.tap()
        }
        
        WaitHelper.waitForElementToBeVisible(dedicatedIPHeader, timeout: defaultTimeout,
                                             onSuccess:{print("successful navigation to dedicated ip screen")}, onFailure:{error in print("dedicatedIPHeader is not visible")})
    }
    
    func activateDedicatedIP (with dedicatedIP:DedicatedIP) {
        guard dedicatedIPTextField.waitForExistence(timeout: defaultTimeout) else {return}
        dedicatedIPTextField.tap()
        dedicatedIPTextField.typeText(dedicatedIP.token)
        button(with:"Activate").tap()
        dedicatedIPList.waitForExistence(timeout: defaultTimeout)
    }
    
    func deleteDedicatedIP() {
        guard dedicatedIPList.waitForExistence(timeout: defaultTimeout) else {return}
    
        let pressDuration: TimeInterval = 1.0
        let sourceCoordinate = dedicatedIPList.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let leftmostCoordinate = coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        sourceCoordinate.press(forDuration: pressDuration, thenDragTo: leftmostCoordinate)
        
        confirmDeleteButton.tap()
        dedicatedIPTextField.waitForExistence(timeout: defaultTimeout)
    }
}
