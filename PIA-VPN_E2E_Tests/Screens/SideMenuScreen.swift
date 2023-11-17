//
//  SideMenuScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 14/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var logOutButton: XCUIElement {
        staticText(with: "Log out")
    }
    
    var settingsButton: XCUIElement {
        staticText(with: "Settings")
    }
}
