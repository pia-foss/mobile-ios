//
//  DashboardScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var dashboardMenuButton: XCUIElement {button(with: PIALibraryAccessibility.Id.Dashboard.menu)}
    var editString: String {getString(key:"menu.accessibility.edit.tile", comment: "Edit")}
    var dashboardEditButton: XCUIElement {button(with: editString)}
    var connectionButton: XCUIElement {button(with: AccessibilityId.Dashboard.connectionButton)}
    var connectedStatusString: String {getString(key:"dashboard.accessibility.vpn.button.isOn", comment: "VPN Connection button. The VPN is currently connected")}
    var connectedStatusLabel: XCUIElement {button(with: connectedStatusString)}
    var disconnectedStatusString: String {getString(key:"dashboard.accessibility.vpn.button.isOff", comment: "VPN Connection button. The VPN is currently disconnected")}
    var disconnectedStatusLabel: XCUIElement {button(with: disconnectedStatusString)}
    var confirmationDialogButton: XCUIElement {button(with: PIALibraryAccessibility.Id.Dialog.destructive)}
    var quickSettingsButton: XCUIElement {cell(with: "QuickSettingsTileCollectionViewCell")}
    var privateBrowserButtonString: String {getString(key:"tiles.quicksetting.private.browser.title", comment: "Private Browser")}
    var privateBrowserButton: XCUIElement {button(with: privateBrowserButtonString)}
    var enableNetworkManagementButton: XCUIElement {button(with: "Enable Network Management")}
    var disableNetworkManagementButton: XCUIElement {button(with: "Disable Network Management")}
    var enableVPNKillSwitchButton: XCUIElement {button(with: "Enable VPN Kill Switch")}
    var disableVPNKillSwitchButton: XCUIElement {button(with: "Disable VPN Kill Switch")}
    var regionTileCollectionViewCell: XCUIElement {cell(with: "RegionTileCollectionViewCell")}
    
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
