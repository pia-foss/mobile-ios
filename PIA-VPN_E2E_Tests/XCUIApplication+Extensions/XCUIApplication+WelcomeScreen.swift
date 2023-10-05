//
//  XCUIApplication+WelcomeScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Laura S on 10/5/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: XCUIApplication + Welcome Screen UI elements

extension XCUIApplication {
  var goToLoginScreenButton: XCUIElement {
    button(with: PIALibraryAccessibility.Id.Login.submitNew)
  }
  
  var goToLoginScreenButtonOldVersion: XCUIElement {
    button(with: PIALibraryAccessibility.Id.Login.submit)
  }
}
