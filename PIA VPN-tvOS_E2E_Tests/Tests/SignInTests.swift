//
//  SignInTests.swift
//  PIA VPN-tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

class SignInTests: BaseTest {
    override class func spec() {
        super.spec()
        
        describe("sign in tests") {
            context("account validation") {
                it("should successfully login with correct credentials") {
                    app.buttons["tvos.welcome.button.login"]
                }
            }
        }
    }
}
