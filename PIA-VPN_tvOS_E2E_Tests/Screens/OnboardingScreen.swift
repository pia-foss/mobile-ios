//
//  OnboardingScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var helpImprovePIATitle: XCUIElement {staticText(with: "Help Improve PIA")}
    var acceptOnboardingButton: XCUIElement {button(with: "Accept")}
    var configurePIATitle: XCUIElement {staticText(with: "Configure PIA")}
    var configurePIAButton: XCUIElement {button(with: "Configure PIA")}
    
    func acceptSharingVPNStats(){
        guard helpImprovePIATitle.waitForExistence(timeout: defaultTimeout) else {return}
        moveFocus(to: acceptOnboardingButton)
        XCUIRemote.shared.press(.select)
    }
    
    func acceptVPNConfiguration(){
        guard configurePIATitle.waitForExistence(timeout: defaultTimeout) else {return}
        moveFocus(to: configurePIAButton)
        XCUIRemote.shared.press(.select)
    }
}
