//
//  SignUpScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 21/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var signupImage: XCUIElement {image(with: "signup-screen")}
    var yearlyPlanButton: XCUIElement {findElementWithPartialText(partialText: L10n.Welcome.Plan.Yearly.title, elementType: .button)!}
    var monthlyPlanButton: XCUIElement {findElementWithPartialText(partialText: L10n.Welcome.Plan.Monthly.title, elementType: .button)!}
    var subscribeNowButton: XCUIElement {button(with: L10n.Localizable.Tvos.Signup.Subscription.Paywall.Button.subscribe)}
    var termsOfServiceButton: XCUIElement {button(with: "Terms of Service")}
    var termsAndConditionsTitle: XCUIElement {staticText(with: L10n.Localizable.Tvos.Signup.TermsConditions.title)}
    
    func selectSignUpPlan(plan: String) {
        switch plan {
        case "Yearly":
            moveFocus(to: yearlyPlanButton)
            XCUIRemote.shared.press(.select)
        case "Monthly":
            moveFocus(to: monthlyPlanButton)
            XCUIRemote.shared.press(.select)
        default:
            moveFocus(to: yearlyPlanButton)
            XCUIRemote.shared.press(.select)
        }
    }
    
    func subscribeNow() {
        moveFocus(to: subscribeNowButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
    }
    
    func navigateToTermsOfService() {
        termsOfServiceButton.waitForElementToAppear()
        moveFocus(to: termsOfServiceButton, startingDirection: .down)
        XCUIRemote.shared.press(.select)
        XCTAssert(termsAndConditionsTitle.waitForElementToAppear())
    }
    
    func navigateBackToSignUp(){
        XCUIRemote.shared.press(.menu)
        XCTAssert(signupImage.waitForElementToAppear())
    }
}
