//
//  XCUIApplication+HomeScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Laura S on 10/6/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
  var dashboardMenuButton: XCUIElement {
    navigationBars.buttons[PIALibraryAccessibility.Id.Dashboard.menu]
  }
  
  var connectionButton: XCUIElement {
    button(with: AccessibilityId.Dashboard.connectionButton)
  }
}
