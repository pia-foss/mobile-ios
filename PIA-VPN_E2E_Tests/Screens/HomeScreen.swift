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
        if(welcomeLoginButton.waitForElementToAppear()) {
            return
        }
        
        dashboardMenuButton.waitForElementToAppear()
        dashboardMenuButton.tap()
        logOutButton.waitForElementToAppear()
        logOutButton.tap()
        confirmationDialogButton.waitForElementToAppear()
        confirmationDialogButton.tap()
        XCTAssert(welcomeLoginButton.waitForElementToAppear())
    }
    
    func navigateToHome(using backToHomeButton: XCUIElement) {
        backToHomeButton.waitForElementToAppear()
        backToHomeButton.tap()
        XCTAssert(connectionButton.waitForElementToAppear())
    }
    
    func enableVPNKillSwitchOnHome() {
        if(disableVPNKillSwitchButton.waitForElementToAppear()){
            return
        }
        enableVPNKillSwitchButton.tap()
    }
    
    func disableVPNKillSwitchOnHome() {
        if(enableVPNKillSwitchButton.waitForElementToAppear()){
            return
        }
        disableVPNKillSwitchButton.tap()
    }
    
    func enableNetworkManagementOnHome() {
        if(disableNetworkManagementButton.waitForElementToAppear()) {
            return
        }
        enableNetworkManagementButton.tap()
    }
    
    func disableNetworkManagementOnHome() {
        if(enableNetworkManagementButton.waitForElementToAppear()) {
            return
        }
        disableNetworkManagementButton.tap()
    }
    
    func connectToVPN() {
        if (connectedStatusLabel.waitForElementToAppear()) {
            return
        }
        connectionButton.tap()
        XCTAssert(connectedStatusLabel.waitForElementToAppear())
    }
    
    func disconnectToVPN() {
        if (disconnectedStatusLabel.waitForElementToAppear()) {
            return
        }
        connectionButton.tap()
        XCTAssert(disconnectedStatusLabel.waitForElementToAppear())
    }
}
