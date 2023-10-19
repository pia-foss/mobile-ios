//
//  PIAExampleWithAuthenticatedAppTest.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Laura S on 10/6/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

/// This is an example of how to setup a XCTestCase
/// with the app on Authenticated state and the VPN Profile installed
/// from the Onboarding flow
final class PIAExampleWithAuthenticatedAppTest: XCTestCase {
  private var app: XCUIApplication!
  
  override func setUpWithError() throws {
    continueAfterFailure = false
    // 1. Instantiate the app process
    app = XCUIApplication(bundleIdentifier: "com.privateinternetaccess.ios.PIA-VPN")
    // 2. Launch the app process
    app.launch()
    
    // 3. Authenticates with valid credentials coming from the Environment variables and installs the VPN Profile
    app.loginAndInstallVPNProfile(from: self)
    
    // NOTE: To add valid credentials in the Environment Variables:
    // - Select `PIA-VPN_E2E_Tests` schema
    // - On the dropdown menu -> Edit Scheme
    // - Tap the 'Run' Button from the left side
    // - Add correct values on the Env Variables called `PIA_TEST_USER` and `PIA_TEST_PASSWORD` -> IMPORTANT: Do not commit these updates
  }
  
  override func tearDownWithError() throws {
    // Terminates the app process everytime a test has finished its execution
    app.terminate()
  }
  
  func testExample() throws {
    
    // Additional test steps here...
  }
  
  
}
