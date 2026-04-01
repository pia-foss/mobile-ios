//
//  BaseTest.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 17/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Nimble
import Quick
import XCTest

class BaseTest: QuickSpec {
    static var app: XCUIApplication!
    static let bundle = Bundle(for: BaseTest.self)

    override class func spec() {
        beforeEach {
            app = XCUIApplication()
            app.launch()
            if (!app.connectionButton.waitForExistence(timeout: app.defaultTimeout)) {
                app.navigateToLoginScreen()
                app.logIn(with: CredentialsUtil.credentials(type: .valid))
                app.acceptVPNPermission()
            }
        }

        afterEach {
            app.terminate()
        }
    }
}
