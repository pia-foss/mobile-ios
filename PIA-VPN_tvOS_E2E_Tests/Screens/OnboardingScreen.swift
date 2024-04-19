//
//  OnboardingScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var helpImprovePIAString: String {getString(key: "settings.service.quality.share.title", comment: "Help Improve PIA")}
    var helpImprovePIATitle: XCUIElement {staticText(with: helpImprovePIAString)}
    var acceptOnboardingButton: XCUIElement {button(with: "Accept")}
    var configurePIATitleString: String {getString(key: "onboarding.vpn_configuration.title", comment: "Configure PIA")}
    var configurePIATitle: XCUIElement {staticText(with: configurePIATitleString)}
    var configurePIAButtonString: String {getString(key: "onboarding.vpn_configuration.button", comment: "Configure PIA")}
    var configurePIAButton: XCUIElement {button(with: configurePIAButtonString)}
    
    func acceptSharingVPNStats(){
        helpImprovePIATitle.waitForElementToAppear()
        moveFocus(to: acceptOnboardingButton)
        XCUIRemote.shared.press(.select)
    }
    
    func acceptVPNConfiguration(){
        configurePIATitle.waitForElementToAppear()
        moveFocus(to: configurePIAButton)
        XCUIRemote.shared.press(.select)
    }
}
