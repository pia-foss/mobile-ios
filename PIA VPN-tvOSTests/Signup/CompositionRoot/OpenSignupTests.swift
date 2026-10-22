//
//  OpenSignupTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import XCTest

@testable import PIA_VPN_tvOS

@MainActor
final class OpenSignupTests: XCTestCase {

    func test_openSignup_withActiveSubscription_opensWelcomeBackOverThePaywall() async {
        // GIVEN this Apple ID holds a live subscription
        let router = AppRouterSpy()

        // WHEN sign up is opened
        await SignUpFactory.openSignup(router: router, hasActiveSubscription: { true })

        // THEN the paywall and welcome-back are pushed together, so the paywall never shows first
        XCTAssertEqual(
            router.requests,
            [.navigate(AuthenticationDestinations.signup), .navigate(AuthenticationDestinations.welcomeBack)])
    }

    func test_openSignup_withoutSubscription_opensThePaywall() async {
        // GIVEN this Apple ID holds no subscription
        let router = AppRouterSpy()

        // WHEN sign up is opened
        await SignUpFactory.openSignup(router: router, hasActiveSubscription: { false })

        // THEN only the paywall is shown
        XCTAssertEqual(router.requests, [.navigate(AuthenticationDestinations.signup)])
    }

    func test_openSignup_whenTheStackChangesDuringTheCheck_doesNotNavigate() async {
        // GIVEN the user navigates elsewhere while the subscription is being checked
        let router = AppRouterSpy()

        // WHEN sign up is opened
        await SignUpFactory.openSignup(
            router: router,
            hasActiveSubscription: {
                router.stackCount += 1
                return true
            })

        // THEN nothing is pushed over wherever the user went
        XCTAssertTrue(router.requests.isEmpty)
    }
}
