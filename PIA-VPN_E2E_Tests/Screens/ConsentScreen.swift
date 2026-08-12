//
//  ConsentScreen.swift
//  PIA-VPN_E2E_Tests
//

import XCTest

extension XCUIApplication {
    var consentAcceptButton: XCUIElement { button(with: PIALibraryAccessibility.Id.Consent.accept) }
    var consentNoThanksButton: XCUIElement { button(with: PIALibraryAccessibility.Id.Consent.noThanks) }

    func dismissConsentScreenIfPresented() {
        if (consentNoThanksButton.waitForElementToAppear(timeout: shortTimeout)) {
            consentNoThanksButton.tap()
        }
    }
}
