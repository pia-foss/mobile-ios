//
//  VPNPermissionScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    
    var vpnPermissionScreen: XCUIElement {
        view(with: AccessibilityId.VPNPermission.screen)
    }
    
    var vpnPermissionButton: XCUIElement{
        button(with: AccessibilityId.VPNPermission.submit)
    }
    
    var vpnPermissionAlertText: XCUIElement{
        alerts["PIA VPN dev” Would Like to Add VPN Configurations"]
    }
    
    var vpnAllowButton: XCUIElement{
        buttons["Allow"].firstMatch
    }
}
