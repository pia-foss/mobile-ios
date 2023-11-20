//
//  DashboardScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var dashboardMenuButton: XCUIElement{
        button(with: PIALibraryAccessibility.Id.Dashboard.menu)
    }
    
    var connectionButton: XCUIElement {
        button(with: AccessibilityId.Dashboard.connectionButton)
    }
    
    var confirmationDialogButton: XCUIElement {
        button(with: PIALibraryAccessibility.Id.Dialog.destructive)
    }
    
    var quickSettingsButton: XCUIElement {
        cell(with: "QuickSettingsTileCollectionViewCell")
    }
    
    var privateBrowserButton: XCUIElement {
        button(with: "Private Browser")
    }
    
    var enableNetworkManagementButton: XCUIElement {
        button(with: "Enable Network Management")
    }
    
    var disableNetworkManagementButton: XCUIElement {
        button(with: "Disable Network Management")
    }
    
    var enableVPNKillSwitchButton: XCUIElement {
        button(with: "Enable VPN Kill Switch")
    }
    
    var disableVPNKillSwitchButton: XCUIElement {
        button(with: "Disable VPN Kill Switch")
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
    
    func navigateToSettings() {
        guard dashboardMenuButton.exists else { return }
        dashboardMenuButton.tap()
        
        if settingsButton.waitForExistence(timeout: defaultTimeout) {
            settingsButton.tap()
        }
    }
    
    func navigateToHomeFromSettings() {
        if settingsBackButton.waitForExistence(timeout: defaultTimeout) {
            settingsBackButton.tap()
            navigateToHome()
        }
    }
    
    func navigateToQuickSettings() {
        quickSettingsButton.staticTexts["QUICK SETTINGS"].tap()
    }
    
    func navigateToHome() {
        closeButton.tap()
        dashboardMenuButton.waitForExistence(timeout: defaultTimeout)
    }
    
    func enableVPNKillSwitchOnHome() {
        if(enableVPNKillSwitchButton.exists) {
            enableVPNKillSwitchButton.tap()
        }
    }
    
    func disableVPNKillSwitchOnHome() {
        if(disableVPNKillSwitchButton.exists) {
            disableVPNKillSwitchButton.tap()
        }
    }
    
    func enableNetworkManagementOnHome() {
        if(enableNetworkManagementButton.exists) {
            enableNetworkManagementButton.tap()
        }
    }
    
    func disableNetworkManagementOnHome() {
        if(disableNetworkManagementButton.exists) {
            disableNetworkManagementButton.tap()
        }
    }
}
