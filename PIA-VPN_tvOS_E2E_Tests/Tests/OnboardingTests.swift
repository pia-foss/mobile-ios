//
//  OnboardingTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 28/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//
import Nimble

class OnboardingTests:BaseTest {
    override class func spec() {
        shouldLogIn = false 
        super.spec()
        
        describe("onboarding tests") {
            context("vpn profile installation permission") {
                it("should display the home screen after allowing vpn profile installation") {
                    app.logout()
                    app.navigateToSignInScreen()
                    app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptSharingVPNStats()
                    app.acceptVPNConfiguration()
                    expect(app.connectButton.waitForElementToAppear()).to(beTrue())
                }
            }
        }
    }
}
