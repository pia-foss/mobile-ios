//
//  ConsentScreen.swift
//  PIA-VPN_E2E_Tests
//

import PIAAccessibility
import XCTest

extension XCUIApplication {
    var consentAcceptButton: XCUIElement { button(with: AccessibilityID.Consent.accept) }
    var consentNoThanksButton: XCUIElement { button(with: AccessibilityID.Consent.noThanks) }

    func dismissConsentScreenIfPresented() {
        if (consentNoThanksButton.waitForElementToAppear(timeout: shortTimeout)) {
            consentNoThanksButton.tap()
        }
    }
}
