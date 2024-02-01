//
//  RootContainerViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 12/19/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
@testable import PIA_VPN_tvOS
import SwiftUI

final class RootContainerViewModelTests: XCTestCase {
    
    final class Fixture {
        let accountProvierMock = AccountProviderTypeMock()
        let notificationCenterMock = NotificationCenterMock()
        var vpnConfigurationAvailabilityMock = VPNConfigurationAvailabilityMock(value: false)
        let appRouterSpy = AppRouterSpy()
        let bootstrapMock = BootstraperMock()
        
        func makeUserAuthenticationStatusMonitorMock(status: UserAuthenticationStatus) -> UserAuthenticationStatusMonitorMock {
            return UserAuthenticationStatusMonitorMock(status: status)
        }
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
        sut = RootContainerViewModel(accountProvider: fixture.accountProvierMock,
                                     notificationCenter: fixture.notificationCenterMock,
                                     vpnConfigurationAvailability: fixture.vpnConfigurationAvailabilityMock, 
                                     bootstrap: fixture.bootstrapMock, 
                                     userAuthenticationStatusMonitor: fixture.makeUserAuthenticationStatusMonitorMock(status: .loggedOut),
                                     appRouter: fixture.appRouterSpy)
        sut.isBootstrapped = bootStrapped
    }
    
    func testState_WhenUserIsNotAuthenticated() {
        // GIVEN that the user is not logged in
        fixture.accountProvierMock.isLoggedIn = false
        
        // WHEN the app is launched
        initializeSut()
        
        // THEN the state becomes 'notActivated'
        XCTAssertEqual(sut.state, .notActivated)
        
        // AND no navigation requests are sent to the router
        XCTAssertEqual(fixture.appRouterSpy.requests, [])
    }
    
    func testState_WhenUserIsAuthenticatedAndVpnProfileNotInstalled() {
        // GIVEN that the user is logged in
        fixture.accountProvierMock.isLoggedIn = true
        // AND GIVEN that the Onboarding Vpn Profile is NOT installed
        stubOnboardingVpnInstallation(finished: false)
        
        // WHEN the app is launched
        initializeSut()
        
        // THEN the state becomes 'activatedNotOnboarded'
        XCTAssertEqual(sut.state, .activatedNotOnboarded)
        
        // AND the router is called to navigate to the Onboarding Install VPN profile
        XCTAssertEqual(fixture.appRouterSpy.requests, [AppRouterSpy.Request.navigate(OnboardingDestinations.installVPNProfile)])
    }
    
    func testState_WhenUserIsAuthenticatedAndVpnProfileInstalled() {
        // GIVEN that the user is logged in
        fixture.accountProvierMock.isLoggedIn = true
        // AND GIVEN that the Onboarding Vpn Profile is installed
        stubOnboardingVpnInstallation(finished: true)
        
        // WHEN the app is launched
        initializeSut()
        
        // THEN the state becomes 'activated'
        XCTAssertEqual(sut.state, .activated)
        
        // AND no navigation requests are sent to the router
        XCTAssertEqual(fixture.appRouterSpy.requests, [])
    }
    
    func testBoostrapperIsCalled_WhenAppIsLaunched() {
        // GIVEN sut is initialized
        // WHEN the app is launched
        initializeSut()
        
        // THEN Boostrapper is called
        XCTAssertEqual(fixture.bootstrapMock.callAsFunctionTimesCalled, 1)
    }
    
    func testState_WhenUserIsNotAuthenticatedAndAuthenticates() {
        // GIVEN that the user is logged out
        fixture.accountProvierMock.isLoggedIn = false
        // AND GIVEN that the Onboarding Vpn Profile not installed
        stubOnboardingVpnInstallation(finished: true)
        
        let userAuthenticationStatusMonitor = fixture.makeUserAuthenticationStatusMonitorMock(status: .loggedOut)
        
        sut = RootContainerViewModel(accountProvider: fixture.accountProvierMock,
                                     notificationCenter: fixture.notificationCenterMock,
                                     vpnConfigurationAvailability: fixture.vpnConfigurationAvailabilityMock,
                                     bootstrap: fixture.bootstrapMock,
                                     userAuthenticationStatusMonitor: userAuthenticationStatusMonitor, 
                                     appRouter: fixture.appRouterSpy)
        
        XCTAssertEqual(sut.state, .notActivated)
        fixture.accountProvierMock.isLoggedIn = true
        
        // WHEN user authenticates
        userAuthenticationStatusMonitor.status.send(.loggedIn)
        
        // THEN the state becomes 'activated'
        XCTAssertEqual(sut.state, .activated)
    }
    
    func testState_WhenUserIsAuthenticatedAndLogsOut() {
        // GIVEN that the user is authenticated
        fixture.accountProvierMock.isLoggedIn = true
        // AND GIVEN that the Onboarding Vpn Profile not installed
        stubOnboardingVpnInstallation(finished: true)
        
        let userAuthenticationStatusMonitor = fixture.makeUserAuthenticationStatusMonitorMock(status: .loggedOut)
        
        sut = RootContainerViewModel(accountProvider: fixture.accountProvierMock,
                                     notificationCenter: fixture.notificationCenterMock,
                                     vpnConfigurationAvailability: fixture.vpnConfigurationAvailabilityMock,
                                     bootstrap: fixture.bootstrapMock,
                                     userAuthenticationStatusMonitor: userAuthenticationStatusMonitor,
                                    appRouter: fixture.appRouterSpy)
        
        XCTAssertEqual(sut.state, .activated)
        fixture.accountProvierMock.isLoggedIn = false
        
        // WHEN user logs out
        userAuthenticationStatusMonitor.status.send(.loggedOut)
        
        // THEN the state becomes 'activated'
        XCTAssertEqual(sut.state, .notActivated)
    }
}


extension RootContainerViewModelTests {
    private func stubOnboardingVpnInstallation(finished: Bool) {
        fixture.vpnConfigurationAvailabilityMock = VPNConfigurationAvailabilityMock(value: finished)
    }
}
