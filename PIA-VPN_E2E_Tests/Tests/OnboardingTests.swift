//
//  OnboardingTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class OnboardingTests:BaseTest {
    override class func spec() {
        super.spec()
        
        describe("onboarding vpn permission tests") {
            context("vpn profile installation permission") {
                it("should display the home screen after allowing vpn profile installation"){
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptVPNPermission()
                    
                    app.vpnPermissionAlertText.waitForExistence(timeout: app.defaultTimeout)
                    app.vpnAllowButton.waitForExistence(timeout: app.defaultTimeout)
                    app.swipeUp()
                    
                    expect(app.dashboardMenuButton.waitForExistence(timeout: app.defaultTimeout))
                    expect(app.vpnPermissionScreen.exists).to(beFalse())
                }
            }
        }
    }
}
