//
//  WelcomeScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var loginButton: XCUIElement {button(with: "Log In")}
    
    func navigateToSignInScreen(){
        guard loginButton.waitForExistence(timeout: defaultTimeout) else {return}
        moveFocus(to: loginButton)
        XCUIRemote.shared.press(.select)
    }
}
