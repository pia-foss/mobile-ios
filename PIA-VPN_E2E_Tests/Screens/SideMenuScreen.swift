//
//  SideMenuScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 14/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var logOutString: String {getString(key: "menu.item.logout", comment: "Log out")}
    var logOutButton: XCUIElement {staticText(with: logOutString)}
    var settingsButtonString: String {getString(key: "menu.item.settings", comment: "Settings")}
    var settingsButton: XCUIElement {staticText(with: settingsButtonString)}
  
    func selectSideMenu(menuName: String) {
        dashboardMenuButton.waitForElementToAppear()
        dashboardMenuButton.tap()
        XCTAssert(staticText(with: menuName).waitForElementToAppear())
        staticText(with: menuName).tap()
        
        XCTAssert(staticText(with: menuName).waitForElementToAppear())
    }
}
