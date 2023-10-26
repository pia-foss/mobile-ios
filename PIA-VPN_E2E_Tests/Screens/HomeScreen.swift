//
//  DashboardScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var dashboardMenuButton: XCUIElement{
        button(with: PIALibraryAccessibility.Id.Dashboard.menu)
    }
    
    var connectionButton: XCUIElement {
        button(with: AccessibilityId.Dashboard.connectionButton)
    }
    
    var confirmationDialogButton: XCUIElement{
        button(with: PIALibraryAccessibility.Id.Dialog.destructive)
    }
    
    var logOutButton: XCUIElement{
        staticText(with: "Log out")
    }
    
    func logOut() {
        guard dashboardMenuButton.exists else { return }
        dashboardMenuButton.tap()
        
        if logOutButton.waitForExistence(timeout: defaultTimeout) {
            logOutButton.tap()
            if confirmationDialogButton.waitForExistence(timeout: shortTimeout) {
                confirmationDialogButton.tap()
            }
            welcomeLoginButton.waitForExistence(timeout: defaultTimeout)
        }
    }
}
