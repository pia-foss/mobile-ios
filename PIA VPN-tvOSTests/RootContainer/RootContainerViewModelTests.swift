//
//  RootContainerViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 12/19/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class RootContainerViewModelTests: XCTestCase {
    
    final class Fixture {
        let accountProvierMock = AccountProviderTypeMock()
        let notificationCenterMock = NotificationCenterMock()
    }

    var fixture: Fixture!
    var sut: RootContainerViewModel!
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        UserDefaults.standard.removeObject(forKey: .kOnboardingVpnProfileInstalled)
    }
    
    private func initializeSut(bootStrapped: Bool = true) {
        sut = RootContainerViewModel(accountProvider: fixture.accountProvierMock, notificationCenter: fixture.notificationCenterMock)
        sut.isBootstrapped = bootStrapped
    }
    
    func testState_WhenUserIsNotAuthenticated() {
        // GIVEN that the user is not logged in
        fixture.accountProvierMock.isLoggedIn = false
        
        initializeSut()
        
        // WHEN the app is launched
        sut.phaseDidBecomeActive()
        
        // THEN the state becomes 'notActivated'
        XCTAssertEqual(sut.state, .notActivated)
    }
    
    func testState_WhenUserIsAuthenticatedAndVpnProfileNotInstalled() {
        // GIVEN that the user is logged in
        fixture.accountProvierMock.isLoggedIn = true
        // AND GIVEN that the Onboarding Vpn Profile is NOT installed
        stubOnboardingVpnInstallation(finished: false)
        
        initializeSut()
        
        // WHEN the app is launched
        sut.phaseDidBecomeActive()
        
        // THEN the state becomes 'activatedNotOnboarded'
        XCTAssertEqual(sut.state, .activatedNotOnboarded)
    }
    
    func testState_WhenUserIsAuthenticatedAndVpnProfileInstalled() {
        // GIVEN that the user is logged in
        fixture.accountProvierMock.isLoggedIn = true
        // AND GIVEN that the Onboarding Vpn Profile is installed
        stubOnboardingVpnInstallation(finished: true)
        
        initializeSut()
        
        // WHEN the app is launched
        sut.phaseDidBecomeActive()
        
        // THEN the state becomes 'activated'
        XCTAssertEqual(sut.state, .activated)
    }
}


extension RootContainerViewModelTests {
    private func stubOnboardingVpnInstallation(finished: Bool) {
        UserDefaults.standard.setValue(finished, forKey: .kOnboardingVpnProfileInstalled)
        UserDefaults.standard.synchronize()
    }
}
