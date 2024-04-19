//
//  SignInScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var usernameTextFieldString: String {getString(key: "tvos.login.placeholder.username", comment: "Enter Username")}
    var usernameTextField: XCUIElement {textField(with: usernameTextFieldString)}
    var unauthorizedErrorString: String {getString(key: "account.error.unauthorized", comment: "Your username or password is incorrect.")}
    var incorrectCredentialsErrorMessage: XCUIElement {staticText(with: unauthorizedErrorString)}
    var loginViaUsernameString: String {getString(key: "tvos.login.qr.button.login", comment: "Log In via Username")}
    var loginViaUsernameButton: XCUIElement {button(with: loginViaUsernameString)}
    
    func loginViaUsername(with credentials: Credentials) {
        loginViaUsernameButton.waitForElementToAppear()
        moveFocus(to: loginViaUsernameButton)
        XCUIRemote.shared.press(.select)
        
        usernameTextField.waitForElementToAppear()
        moveFocus(to: usernameTextField)
        XCUIRemote.shared.press(.select)
        
        let navigator = KeyboardNavigator()
        navigator.resetKeyboardPosition()
        navigator.typeText(credentials.username, keyboardType: .multiRow)
        navigator.clickNext()
        
        navigator.typeText(credentials.password, keyboardType: .multiRow)
        navigator.clickNext()
    }
}
