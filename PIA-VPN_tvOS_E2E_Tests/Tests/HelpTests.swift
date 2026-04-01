//
//  HelpTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble

class HelpTests: BaseTest {
    override class func spec() {
        shouldLogIn = true
        super.spec()
        
        describe("help tests") {
            context("when the user navigates to the help screen") {
                it("should display the following: app version, about, help improve PIA, and contact support qr") {
                    app.navigateToHelpScreen()
                    expect(app.appVersion.waitForElementToAppear()).to(beTrue())
                    expect(app.aboutButton.waitForElementToAppear()).to(beTrue())
                    expect(app.helpImprovePIAButton.waitForElementToAppear()).to(beTrue())
                    expect(app.scanQRCodeContactUsMessage.waitForElementToAppear()).to(beTrue())
                }
            }
            
            context("when the user navigates to about screen") {
                it("should display the privacy policy screen, and the privacy policy qr upon navigating to it") {
                    app.navigateToHelpScreen()
                    app.navigateToAboutScreen()
                    app.navigateToPrivacyPolicyScreen()
                    expect(app.privacyPolicyMessage.waitForElementToAppear()).to(beTrue())
                    expect(app.scanQRCodePrivacyPolicyMessage.waitForElementToAppear()).to(beTrue())
                }
                
                it("should display the acknowledgments screen, and the third party contents and services upon navigating to it") {
                    app.navigateToHelpScreen()
                    app.navigateToAboutScreen()
                    app.navigateToAcknowledgmentsScreen()
                    expect(app.acknowledgementsMessage.waitForElementToAppear()).to(beTrue())
                }
            }
        }
    }
}
