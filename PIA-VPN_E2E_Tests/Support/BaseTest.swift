//
//  BaseTest.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

/// Launches the app before each test, signing in with the valid test account when the dashboard isn't showing,
/// and terminates it afterwards.
class BaseTest: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        app = XCUIApplication()
        // Run the app in English whatever the device language, to match `getString` and the hardcoded labels.
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        // Debug builds only (Bootstrapper): start from the same kill switch, Automation and geo-located regions settings
        // whatever earlier tests changed, and skip UIKit animations.
        app.launchArguments += ["-UITestsResetSettings", "-UITestsDisableAnimations"]
        app.launch()
        if !app.connectionButton.waitForExistence(timeout: app.defaultTimeout) {
            app.navigateToLoginScreen()
            app.logIn(with: Credentials.valid)
            app.acceptVPNPermission()
        }
    }

    /// Skips the test on the Simulator, where the VPN tunnel (a Network Extension) can't run.
    func requireRealDevice() throws {
        #if targetEnvironment(simulator)
            throw XCTSkip("Needs a real device: the VPN tunnel can't run on the Simulator")
        #endif
    }

    override func tearDown() {
        app?.terminate()
        app = nil
        super.tearDown()
    }
}
