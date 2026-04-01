//
//  SignInTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble

class SignInTests:BaseTest {
    override class func spec() {
        shouldLogIn = false 
        super.spec()
        describe("sign in tests"){
            context("account validations"){
                it("should successfully sign in with valid credentials"){
                    app.logout()
                    app.navigateToSignInScreen()
                    app.loginViaUsername(with: CredentialsUtil.credentials(type: .valid))
                    expect(app.helpImprovePIATitle.waitForElementToAppear()).to(beTrue())
                }
                
                it("should display error mesages with invalid credentials"){
                    app.logout()
                    app.navigateToSignInScreen()
                    app.loginViaUsername(with: CredentialsUtil.credentials(type: .invalid))
                    expect(app.incorrectCredentialsErrorMessage.waitForElementToAppear()).to(beTrue())
                }
            }
        }
    }
}
