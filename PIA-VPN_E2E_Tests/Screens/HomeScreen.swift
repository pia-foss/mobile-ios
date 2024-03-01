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
    
    var dashboardEditButton: XCUIElement{
        button(with: "Edit")
    }
    
    var connectionButton: XCUIElement {
        button(with: AccessibilityId.Dashboard.connectionButton)
    }
    
    var connectedStatusLabel: XCUIElement {
        button(with: "VPN Connection button. The VPN is currently connected")
    }
    
    var disconnectedStatusLabel: XCUIElement {
        button(with: "VPN Connection button. The VPN is currently disconnected")
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
    
    var regionTileCollectionViewCell: XCUIElement {
        cell(with: "RegionTileCollectionViewCell")
    }
    
    func logOut() {
        guard dashboardMenuButton.waitForExistence(timeout: defaultTimeout) else { return }
        dashboardMenuButton.tap()
        
        guard logOutButton.waitForExistence(timeout: defaultTimeout) else {return}
        logOutButton.tap()
        guard confirmationDialogButton.waitForExistence(timeout: shortTimeout) else{return}
        confirmationDialogButton.tap()
        WaitHelper.waitForElementToBeVisible(welcomeLoginButton, timeout: defaultTimeout,
                                                 onSuccess:{print("successful logout")}, onFailure:{error in print("welcomeLoginButton is not visible")})
    }
    
    func navigateToHome(using backToHomeButton: XCUIElement) {
        guard backToHomeButton.waitForExistence(timeout: defaultTimeout) else {return}
        backToHomeButton.tap()
        WaitHelper.waitForElementToBeVisible(dashboardMenuButton, timeout: defaultTimeout,
                                             onSuccess:{print("successful navigation to Home screen")}, onFailure:{error in print("dashboardMenuButton is not visible")})
    }
    
    func enableVPNKillSwitchOnHome() {
        if(enableVPNKillSwitchButton.waitForExistence(timeout: defaultTimeout)) {
            enableVPNKillSwitchButton.tap()
        }
    }
    
    func disableVPNKillSwitchOnHome() {
        if(disableVPNKillSwitchButton.waitForExistence(timeout: defaultTimeout)) {
            disableVPNKillSwitchButton.tap()
        }
    }
    
    func enableNetworkManagementOnHome() {
        if(enableNetworkManagementButton.waitForExistence(timeout: defaultTimeout)) {
            enableNetworkManagementButton.tap()
        }
    }
    
    func disableNetworkManagementOnHome() {
        if(disableNetworkManagementButton.waitForExistence(timeout: defaultTimeout)) {
            disableNetworkManagementButton.tap()
        }
    }
    
    func connectToVPN() {
        if (disconnectedStatusLabel.waitForExistence(timeout: defaultTimeout)) {
            connectionButton.tap()
        }
    }
    
    func disconnectToVPN() {
        if (connectedStatusLabel.waitForExistence(timeout: defaultTimeout)) {
            connectionButton.tap()
        }
    }
}
