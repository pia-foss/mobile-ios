//
//  PIAOnboardingVPNPermissionE2ETests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Laura S on 10/5/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

final class PIAOnboardingVPNPermissionE2ETests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: "com.privateinternetaccess.ios.PIA-VPN")
        launchAppAndAuthenticate()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func launchAppAndAuthenticate() {
        dismissNotificationsPermissionAlertIfNeeded()
        app.launch()
        app.logOutIfNeeded()
        app.navigateToLoginScreenIfNeeded()
        app.fillLoginScreen(with: CredentialsUtil.credentials(type: .valid))
        
        guard app.loginButton.exists else {
            XCTFail("XCUIApplication: failed to find LOGIN button in screen to authenticate user")
            return
        }
        
        app.loginButton.tap()
        
        guard app.willDisplayVpnPermissionScreen else {
            XCTFail("XCUIApplication: login failed")
            return
        }
    }
    
    private func allowVPNProfileInstallationWhenRequested() {
        addUIInterruptionMonitor(withDescription: "Vpn permission dialog") { element in
            let vpnPermissionAlertText = "“PIA VPN dev” Would Like to Add VPN Configurations"
            let isVPNPermissionAlert = element.elementType == .alert &&
                                        element.staticTexts[vpnPermissionAlertText].exists
            
            let allowButton = element.buttons["Allow"].firstMatch
            if isVPNPermissionAlert && allowButton.exists {
                allowButton.tap()
                return true
            } else {
                return false
            }
        }
    }
    
    func testAllowVPNProfileInstallation() throws {
        let vpnPermissionScreen = app.view(with: AccessibilityId.VPNPermission.screen)
        let vpnPermissionButton = app.button(with: AccessibilityId.VPNPermission.submit)
        
        XCTContext.runActivity(named: "GIVEN that the Vpn Permission screen is shown") { _ in
            XCTAssertTrue(vpnPermissionScreen.exists)
            XCTAssertTrue(vpnPermissionButton.exists)
        }
        
        XCTContext.runActivity(named: "WHEN giving consent to install the VPN profile") { _ in
            allowVPNProfileInstallationWhenRequested()
            vpnPermissionButton.tap()
            
            // Do some action on the app so that the system alert is handled
            app.swipeUp()
        }
        
        XCTContext.runActivity(named: "THEN the Home screen is shown") { _ in
            let dashboardMenuButtonExists =  app.dashboardMenuButton.waitForExistence(timeout: app.defaultTimeout)
            
            XCTAssertTrue(dashboardMenuButtonExists)
        }
        
        XCTContext.runActivity(named: "AND the VPN Permission screen is NOT shown") { _ in
            XCTAssertFalse(app.willDisplayVpnPermissionScreen)
        }
    }
    
}

extension PIAOnboardingVPNPermissionE2ETests {
    /* Dismisses only the system alert about sending Notifications Permission.
     Sometimes this alert appears unexpectedly
     when the app launches.
     This makes not possible to continue with the test
     since the rest of the UI becomes not interactable */
    private func dismissNotificationsPermissionAlertIfNeeded() {
        addUIInterruptionMonitor(withDescription: "Notifications permission alert") { element in
            let vpnPermissionAlertText = "“PIA VPN dev” Would Like to Send You Notifications"
            let isNotificationsPermissionAlert = element.elementType == .alert &&
                                        element.staticTexts[vpnPermissionAlertText].exists
            
            let allowButton = element.buttons["Allow"].firstMatch
            if isNotificationsPermissionAlert && allowButton.exists {
                allowButton.tap()
                return true
            } else {
                return false
            }
        }
    }
}
