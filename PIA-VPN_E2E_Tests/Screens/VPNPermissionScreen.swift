//
//  VPNPermissionScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var vpnPermissionScreen: XCUIElement {otherElement(with: AccessibilityId.VPNPermission.screen)}
    var vpnPermissionLabel: XCUIElement {staticText(with: "PIA needs access to your VPN profiles to secure your traffic")}
    var vpnPermissionButton: XCUIElement {button(with: AccessibilityId.VPNPermission.submit)}
    var vpnPermissionAlertText: XCUIElement {alert(with: "PIA VPN dev” Would Like to Add VPN Configurations")}
    var vpnAllowButton: XCUIElement {button(with: "Allow").firstMatch}
    
    func acceptVPNPermission() {
        vpnPermissionLabel.waitForElementToAppear()
        vpnPermissionButton.waitForElementToAppear()
        vpnPermissionButton.tap()
        XCTAssertTrue(connectionButton.waitForElementToAppear())
    }
}
