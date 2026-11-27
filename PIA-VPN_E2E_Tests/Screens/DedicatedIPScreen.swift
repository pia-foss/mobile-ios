//
//  DedicatedIPScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import PIAAccessibility
import XCTest

extension XCUIApplication {
    var dedicatedIPTitleString: String { getString(key: "dedicated.ip.title", comment: "Enter Your Dedicated IP Token") }
    var dedicatedIPHeader: XCUIElement { staticText(with: dedicatedIPTitleString) }
    var dedicatedIPTextFieldString: String { getString(key: "dedicated.ip.token.textfield.accessibility", comment: "The textfield to type the Dedicated IP token") }
    var dedicatedIPTextField: XCUIElement { textField(with: dedicatedIPTextFieldString) }
    var dedicatedIPList: XCUIElement { cells.containing(.any, identifier: AccessibilityID.DedicatedIP.row).firstMatch }
    var invalidTokenErrorString: String { getString(key: "dedicated.ip.message.invalid.token", comment: "Your token is invalid. Please make sure you have entered the token correctly.") }
    var invalidTokenErrorMessage: XCUIElement { staticText(with: invalidTokenErrorString) }
    var emptyTokenErrorString: String { getString(key: "dedicated.ip.message.incorrect.token", comment: "Please make sure you have entered the token correctly") }
    var emptyTokenErrorMessage: XCUIElement { staticText(with: emptyTokenErrorString) }
    var removeString: String { getString(key: "global.remove", comment: "Remove") }
    var deleteTokenButton: XCUIElement { buttons[removeString].firstMatch }
    var confirmDeleteButton: XCUIElement { alerts.buttons[removeString] }
    var activateDedicatedIPButton: XCUIElement { button(with: getString(key: "dedicated.ip.activate.button.title", comment: "Activate")) }

    /// The listed dedicated IP's region name, e.g. "JP Tokyo".
    var dedicatedIPName: String { dedicatedIPRowTexts.first ?? "" }
    /// The listed dedicated IP's address.
    var dedicatedIPAddress: String {
        dedicatedIPRowTexts.first { $0.range(of: ipv4Pattern, options: .regularExpression) != nil } ?? ""
    }
    private var dedicatedIPRowTexts: [String] { dedicatedIPList.staticTexts.allElementsBoundByIndex.map(\.label) }

    func navigateToDedicatedIPScreen() {
        selectSideMenu(menuName: dedicatedIPTitleString)
        XCTAssertTrue(dedicatedIPHeader.waitForElementToAppear())
    }

    func activateDedicatedIP(with dedicatedIP: DedicatedIP) {
        XCTAssertTrue(dedicatedIPTextField.waitForElementToAppear(), "Dedicated IP token field not found")
        dedicatedIPTextField.tap()
        dedicatedIPTextField.typeText(dedicatedIP.token)
        activateDedicatedIPButton.tap()
    }

    func deleteDedicatedIP() {
        XCTAssertTrue(dedicatedIPList.waitForElementToAppear())
        dedicatedIPList.swipeLeft()
        XCTAssertTrue(deleteTokenButton.waitForElementToAppear())
        deleteTokenButton.tap()
        XCTAssertTrue(confirmDeleteButton.waitForElementToAppear())
        confirmDeleteButton.tap()
        XCTAssertTrue(dedicatedIPTextField.waitForElementToAppear())
    }
}
