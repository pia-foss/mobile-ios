//
//  SignUpTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 20/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble

class SignUpTests: BaseTest {
    override class func spec(){
        shouldLogIn = false 
        super.spec()
        
        describe("sign up tests") {
            context("when navigating to sign up page") {
                it("should display the plan selection") {
                    app.logout()
                    app.navigateToSignUpScreen()
                    expect(app.yearlyPlanButton.waitForElementToAppear()).to(beTrue())
                    expect(app.monthlyPlanButton.waitForElementToAppear()).to(beTrue())
                }
            }
            
            context("when clicking the footer navigations"){
                it("should navigate to Privacy Policy page") {
                    app.logout()
                    app.navigateToSignUpScreen()
                    app.navigateToPrivacyPolicyScreen()
                    expect(app.privacyPolicyTitle.waitForElementToAppear()).to(beTrue())
                    app.navigateBackToSignUp()
                    app.navigateToTermsOfService()
                    expect(app.termsAndConditionsTitle.waitForElementToAppear()).to(beTrue())
                }
            }
        }
    }
}
