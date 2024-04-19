//
//  HelpScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var helpTitleString: String {getString(key: "settings.section.help", comment: "Help")}
    var helpTitle: XCUIElement {staticText(with: helpTitleString)}
    var appVersionString: String {getString(key: "help_menu.app_version_section.title", comment: "App Version")}
    var appVersion: XCUIElement {staticText(with: appVersionString)}
    var aboutTitleString: String {getString(key: "menu.item.about", comment: "About")}
    var aboutButton: XCUIElement {button(with: aboutTitleString)}
    var helpImprovePIAButton: XCUIElement {findElementWithPartialText(partialText: helpImprovePIAString, elementType: .button)!}
    var supportQRMessageString: String {getString(key: "help_menu.contact_support.qr_code.message", comment: "Scan the QR code to get in touch to our Support Team.")}
    var scanQRCodeContactUsMessage: XCUIElement {staticText(with: supportQRMessageString)}
    var aboutTitle: XCUIElement {staticText(with: aboutTitleString)}
    var privacyPolicyButtonString: String {getString(key: "help_menu.about_options.privacy_policy.title", comment: "Privacy Policy")}
    var privacyPolicyButton: XCUIElement {button(with: privacyPolicyButtonString)}
    var acknowledgementsButtonString: String {getString(key: "help_menu.about_options.acknowledgements.title", comment: "Acknowledgements")}
    var acknowledgementsButton: XCUIElement {button(with: acknowledgementsButtonString)}
    var privacyPolicyTitle: XCUIElement {staticText(with: privacyPolicyButtonString)}
    var privacyPolicyMessageString: String {getString(key: "help_menu.about_section.privacy_policy.description", comment: "This privacy policy ('Privacy Policy' or 'Policy') explains the privacy practices of Private Internet Access, Inc.,")}
    var privacyPolicyMessage: XCUIElement {findElementWithPartialText(partialText: privacyPolicyMessageString, elementType: .staticText)!}
    var scanQRCodePrivacyPolicyMessageString: String{getString(key: "help_menu.about_section.privacy_policy.qr_code.message", comment: "Scan the QR code to access the full privacy policy on your device.")}
    var scanQRCodePrivacyPolicyMessage: XCUIElement {staticText(with: scanQRCodePrivacyPolicyMessageString)}
    var acknowledgementsTitle: XCUIElement {staticText(with: acknowledgementsButtonString)}
    var acknowledgementsMessageString: String{getString(key: "help_menu.about_section.acknowledgments.copyright.description", comment: "Our Software as a Service (SaaS) platform may occasionally include third-party content, services, or integrations to enhance user experience and functionality.")}
    var acknowledgementsMessage: XCUIElement {findElementWithPartialText(partialText: acknowledgementsMessageString, elementType: .staticText)!}
    
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
