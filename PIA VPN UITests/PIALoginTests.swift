//
//  PIALoginTests.swift
//  PIA VPN UITests
//
//  Created by Waleed Mahmood on 01.03.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import PIALibrary
import Pods_PIA_VPN_dev
import XCTest

class PIALoginTests: XCTestCase {

    static let timeoutUIOps: TimeInterval = 10.0
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        logOutIfSignedIn()
    }

    override func tearDownWithError() throws {
        // when test finishes logout
        logOutIfSignedIn()
    }

    private func logOutIfSignedIn() {
        // check if we have a side menu
        if app.navigationBars.buttons[Accessibility.Id.Dashboard.menu].exists {
            openSideMenuAndTapLogout()
        }
    }

    private func openSideMenuAndTapLogout() {
        app.navigationBars.buttons[Accessibility.Id.Dashboard.menu].tap()

        if app.cells[Accessibility.Id.Menu.logout].waitForExistence(timeout: PIALoginTests.timeoutUIOps) {
            app.cells[Accessibility.Id.Menu.logout].tap()
        } else {
            XCTAssert(false, "PIALoginTests:: A side menu is found but no logout cell is found")
        }
        if app.buttons[Accessibility.Id.Dialog.destructive].waitForExistence(timeout: PIALoginTests.timeoutUIOps) {
            app.buttons[Accessibility.Id.Dialog.destructive].tap()
        } else {
            XCTAssert(false, "PIALoginTests:: Logout alert destructive button is not found")
        }
    }

    private func navigateToLoginViewController() {
        // The signup paywall keeps the historical `id.login.submit` identifier on its Log In button.
        // The previous `submitNew` fallback referenced an identifier that was never declared, so
        // this target did not compile.
        let loginButton = app.buttons[Accessibility.Id.Login.submit]

        guard loginButton.waitForExistence(timeout: PIALoginTests.timeoutUIOps) else {
            XCTAssert(false, "PIALoginTests:: The Log In button on the signup paywall is not identifiable or has moved")
            return
        }

        loginButton.tap()
    }

    private func fillLoginScreen(with credentials: Credentials) {
        let usernameTextField = app.textFields[Accessibility.Id.Login.username]
        let passwordTextField = app.secureTextFields[Accessibility.Id.Login.password]

        if usernameTextField.exists && passwordTextField.exists {
            // Type username
            usernameTextField.tap()
            usernameTextField.typeText(credentials.username)

            // Type password
            passwordTextField.tap()
            passwordTextField.typeText(credentials.password)
        } else {
            XCTAssert(false, "PIALoginTests:: Username and Password text fields on LoginViewController are either not identifiable or are moved")
        }
    }

    private func loginUser(ofType: CredentialsType) {
        navigateToLoginViewController()
        switch ofType {
        case .valid:
            fillLoginScreen(with: CredentialsUtil.credentials(type: .valid))
        case .expired:
            fillLoginScreen(with: CredentialsUtil.credentials(type: .expired))
        case .invalid:
            fillLoginScreen(with: CredentialsUtil.credentials(type: .invalid))
        }

        let loginButton = app.buttons[Accessibility.Id.Login.submit]
        loginButton.tap()
    }

    func testInvalidUserLogin() throws {
        loginUser(ofType: .invalid)

        let bannerViewExists = app.staticTexts["Your username or password is incorrect."].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        XCTAssertTrue(bannerViewExists, "PIALoginTests::testInvalidUserLogin() failed")
    }

    func testExpiredUserLogin() throws {
        app.switchEnvironment(to: .staging)
        loginUser(ofType: .expired)

        let bannerViewExists = app.staticTexts["Your username or password is incorrect."].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        XCTAssertTrue(bannerViewExists, "PIALoginTests::testExpiredUserLogin() failed")
    }

    func testValidUserLogin() throws {
        app.switchEnvironment(to: .production)
        loginUser(ofType: .valid)

        let viewTitleExists = app.staticTexts["PIA needs access to your VPN profiles to secure your traffic"].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        let okButtonExist = app.buttons[Accessibility.Id.Permissions.submit].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        XCTAssertTrue(viewTitleExists && okButtonExist, "PIALoginTests::testActiveUserLogin() failed")
    }
}

private extension XCUIApplication {

    func switchEnvironment(to environment: Client.Environment) {
        // wait until the button is available
        _ = self.buttons[Accessibility.Id.Welcome.environment].waitForExistence(timeout: PIALoginTests.timeoutUIOps)
        let environmentButton = self.buttons[Accessibility.Id.Welcome.environment]

        if environmentButton.label.lowercased() != environment.rawValue.lowercased() {

            // then click it to switch environment
            environmentButton.tap()
        }
    }
}
