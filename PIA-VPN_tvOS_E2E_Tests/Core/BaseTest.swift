//
//  BaseTest.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

/// Launches the app before each test, signing in with the valid test account when `shouldLogIn` is true and the
/// dashboard isn't showing, and terminates it afterwards.
class BaseTest: XCTestCase {
    static let bundle = Bundle(for: BaseTest.self)

    /// Whether `setUp` signs in before each test. Test classes that drive the sign-in flow themselves override it.
    class var shouldLogIn: Bool { true }

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        initializeApp()
        configureAppSettings()
        attemptLoginIfNeeded()
    }

    override func tearDown() {
        terminateApp()
        app = nil
        super.tearDown()
    }

    func initializeApp() {
        app = XCUIApplication()
        app.launch()
    }

    func configureAppSettings() {
        if app.helpImprovePIATitle.exists {
            app.acceptSharingVPNStats()
            app.acceptVPNConfiguration()
        }
    }

    func attemptLoginIfNeeded() {
        if Self.shouldLogIn && !app.connectButton.exists {
            performLoginProcess()
        }
    }

    func performLoginProcess() {
        XCTAssertTrue(app.signinImage.waitForElementToAppear(timeout: 5), "Sign-in image did not appear")

        app.navigateToSignInScreen()
        app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
        app.acceptSharingVPNStats()
        app.acceptVPNConfiguration()
    }

    func relaunchApp() {
        app.launch()
        configureAppSettings()
    }

    func terminateApp() {
        app?.terminate()
    }
}
