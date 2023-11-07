//
//  SignInTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class SignInTests: BaseTest {
    override class func spec(){
        super.spec()
        
        describe("test sign-in") {
            context("account validations") {
                it("should successfully sign in with valid credentials") {
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    expect(app.vpnPermissionScreen.waitForExistence(timeout:app.defaultTimeout))
                }
                
                it("should display error mesages with invalid credentials") {
                    app.logIn(with: CredentialsUtil.credentials(type: .invalid))
                    expect(app.loginErrorMessage.waitForExistence(timeout: app.shortTimeout))
                    expect(app.vpnPermissionScreen.waitForExistence(timeout:app.defaultTimeout)).to(beFalse())
                }
            }
        }
    }
}
