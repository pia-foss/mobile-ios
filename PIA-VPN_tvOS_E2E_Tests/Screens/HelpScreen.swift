//
//  HelpScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var helpTitle:XCUIElement {staticText(with: "Help")}
    var appVersion:XCUIElement {staticText(with: "App Version")}
    var aboutButton:XCUIElement {button(with: "About")}
    var helpImprovePIAButton:XCUIElement {findElementWithPartialText(partialText: "Help Improve PIA", elementType: .button)!}
    var scanQRCodeContactUsMessage:XCUIElement {staticText(with: "Scan the QR code to get in touch to our Support Team.")}
    var aboutTitle:XCUIElement {staticText(with: "About")}
    var privacyPolicyButton:XCUIElement {button(with: "Privacy Policy")}
    var acknowledgementsButton:XCUIElement {button(with: "Acknowledgements")}
    var privacyPolicyTitle:XCUIElement {staticText(with: "Privacy Policy")}
    var privacyPolicyMessage: XCUIElement {findElementWithPartialText(partialText: "This privacy policy ('Privacy Policy' or 'Policy') explains the privacy practices of Private Internet Access, Inc.,", elementType: .staticText)!}
    var scanQRCodePrivacyPolicyMessage:XCUIElement {staticText(with: "Scan the QR code to access the full privacy policy on your device.")}
    var acknowledgementsTitle:XCUIElement {staticText(with: "Acknowledgements")}
    var acknowledgementsMessage:XCUIElement {findElementWithPartialText(partialText: "Our Software as a Service (SaaS) platform may occasionally include third-party content, services, or integrations to enhance user experience and functionality.", elementType: .staticText)!}
    
    func navigateToAboutScreen(){
        aboutButton.waitForElementToAppear()
        moveFocus(to: aboutButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
        XCTAssert(aboutTitle.waitForElementToAppear())
    }
    
    func navigateToPrivacyPolicyScreen(){
        privacyPolicyButton.waitForElementToAppear()
        moveFocus(to: privacyPolicyButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
        XCTAssert(privacyPolicyTitle.waitForElementToAppear())
    }
    
    func navigateToAcknowledgmentsScreen(){
        acknowledgementsButton.waitForElementToAppear()
        moveFocus(to: acknowledgementsButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
        XCTAssert(acknowledgementsTitle.waitForElementToAppear())
    }
}
