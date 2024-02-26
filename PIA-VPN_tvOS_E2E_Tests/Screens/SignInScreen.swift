//
//  SignInScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var usernameTextField: XCUIElement {textField(with: "Enter Username")}
    var incorrectCredentialsErrorMessage: XCUIElement {staticText(with: "Your username or password is incorrect.")}
    
    func login(with credentials: Credentials) {
        guard usernameTextField.waitForExistence(timeout: defaultTimeout) else {return}
        moveFocus(to: usernameTextField)
        XCUIRemote.shared.press(.select)
        
        let navigator = KeyboardNavigator()
        navigator.resetKeyboardPosition()
        navigator.typeText(credentials.username)
        navigator.clickNext()
        
        navigator.typeText(credentials.password)
        navigator.clickNext()
    }
}