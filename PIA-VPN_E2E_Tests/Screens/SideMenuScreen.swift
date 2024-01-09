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
    
    func selectSideMenu(menuName: String) {
           guard dashboardMenuButton.waitForExistence(timeout: defaultTimeout) else { return }
           dashboardMenuButton.tap()
           
           if staticText(with: menuName).waitForExistence(timeout: defaultTimeout) {
               staticText(with: menuName).tap()
           }
           
           WaitHelper.waitForElementToBeVisible(staticText(with: menuName), timeout: defaultTimeout,
                                                onSuccess:{print("successful navigation")}, onFailure:{error in print("side menu is not visible")})
       }
}
