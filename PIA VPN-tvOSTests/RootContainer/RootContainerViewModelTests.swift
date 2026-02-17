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
        let accountProvierMock = AccountProviderMock(userResult: nil, errorResult: nil)
        let notificationCenterMock = NotificationCenterMock()
        var vpnConfigurationAvailabilityMock = VPNConfigurationAvailabilityMock(value: false)
        var connectionStatsPermissonMock = ConnectionStatsPermissonMock(value: nil)
        let appRouterSpy = AppRouterSpy()
        let bootstrapMock = BootstraperMock()
        let connectionStatusMonitorMock = ConnectionStateMonitorMock()
        let refreshLatencyUseCaseMock = RefreshServersLatencyUseCaseMock()
        var userAuthenticationStatusMonitorMock = UserAuthenticationStatusMonitorMock(status: .loggedOut)
        
        func stubUserAuthenticationStatusMonitor(status: UserAuthenticationStatus) {
            self.userAuthenticationStatusMonitorMock = UserAuthenticationStatusMonitorMock(status: status)
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
    }
    
    private func instantiateSut(bootStrapped: Bool = true) {
        sut = RootContainerViewModel(
            accountProvider: fixture.accountProvierMock,
            notificationCenter: fixture.notificationCenterMock,
            vpnConfigurationAvailability: fixture.vpnConfigurationAvailabilityMock,
            connectionStatsPermissonType: fixture.connectionStatsPermissonMock,
            bootstrap: fixture.bootstrapMock,
            userAuthenticationStatusMonitor: fixture.userAuthenticationStatusMonitorMock,
            appRouter: fixture.appRouterSpy,
            refreshLatencyUseCase: fixture.refreshLatencyUseCaseMock
        )
        sut.isBootstrapped = bootStrapped
    }
    
    func testState_WhenUserIsNotAuthenticated() {
        // GIVEN that the user is not logged in
        fixture.accountProvierMock.isLoggedIn = false
        
        // WHEN the app is launched
        instantiateSut()
        
        // THEN the state becomes 'notActivated'
        XCTAssertEqual(sut.state, .notActivated)
        
        // AND no navigation requests are sent to the router
        XCTAssertEqual(fixture.appRouterSpy.requests, [AppRouterSpy.Request.goBackToRoot])
    }
    
    func testState_WhenUserIsAuthenticatedAndAccountIsExpired() {
        // GIVEN that the user is logged in
        fixture.accountProvierMock.isLoggedIn = true
        
        // AND GIVEN user account is expired
        fixture.accountProvierMock.isExpired = true
        
        // WHEN the app is launched
        instantiateSut()
        
        // THEN the state becomes 'activatedNotOnboarded'
        XCTAssertEqual(sut.state, .expired)
    }
    
    func testState_WhenUserIsAuthenticatedAndConnectionStatsPermissonNotShown() {
        // GIVEN that the user is logged in
        fixture.accountProvierMock.isLoggedIn = true
        
        
        // AND GIVEN that the Onboarding Vpn Profile is NOT installed
        stubOnboardingVpnInstallation(finished: false)
        
        // WHEN the app is launched
        instantiateSut()
        
        // THEN the state becomes 'activatedNotOnboarded'
        XCTAssertEqual(sut.state, .activatedNotOnboarded)
        
        // AND the router is called to navigate to the Onboarding Install VPN profile
        XCTAssertEqual(fixture.appRouterSpy.requests, [AppRouterSpy.Request.goBackToRoot, AppRouterSpy.Request.navigate(OnboardingDestinations.connectionstats)])
    }
    
    func testState_WhenUserIsAuthenticatedAndVpnProfileNotInstalled() {
        // GIVEN that the user is logged in
        fixture.accountProvierMock.isLoggedIn = true
        // AND GIVEN that Connection Stats Permisson was shown
        stubConnectionStatsPermisson(value: true)
        // AND GIVEN that the Onboarding Vpn Profile is NOT installed
        stubOnboardingVpnInstallation(finished: false)
        
        // WHEN the app is launched
        instantiateSut()
        
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
        instantiateSut()
        
        // THEN the state becomes 'activated'
        XCTAssertEqual(sut.state, .activated)
        
        // AND no navigation requests are sent to the router
        XCTAssertEqual(fixture.appRouterSpy.requests, [])
    }
    
    func testBoostrapperIsCalled_WhenAppIsLaunched() {
        // GIVEN sut is initialized
        // WHEN the app is launched
        instantiateSut()
        
        // THEN Boostrapper is called
        XCTAssertEqual(fixture.bootstrapMock.callAsFunctionTimesCalled, 1)
    }
    
    func testState_WhenUserIsNotAuthenticatedAndAuthenticates() {
        // GIVEN that the user is logged out
        fixture.accountProvierMock.isLoggedIn = false
        fixture.stubUserAuthenticationStatusMonitor(status: .loggedOut)
        // AND GIVEN that the Onboarding Vpn Profile not installed
        stubOnboardingVpnInstallation(finished: true)
        
        instantiateSut()
        
        XCTAssertEqual(sut.state, .notActivated)
        fixture.accountProvierMock.isLoggedIn = true
        
        // WHEN user authenticates
        fixture.userAuthenticationStatusMonitorMock.status.send(.loggedIn)
        
        // THEN the state becomes 'activated'
        XCTAssertEqual(sut.state, .activated)
    }
    
    func testState_WhenUserIsNotAuthenticatedAndAuthenticatesAndAccountIsExpired() {
        // GIVEN that the user is logged out
        fixture.accountProvierMock.isLoggedIn = false
        fixture.stubUserAuthenticationStatusMonitor(status: .loggedOut)
        // AND GIVEN that the Onboarding Vpn Profile not installed
        stubOnboardingVpnInstallation(finished: true)
        
        instantiateSut()
        
        XCTAssertEqual(sut.state, .notActivated)
        fixture.accountProvierMock.isLoggedIn = true
        
        // WHEN account is expired
        fixture.accountProvierMock.isExpired = true
        // AND authenticates
        fixture.userAuthenticationStatusMonitorMock.status.send(.loggedIn)
        
        // THEN the state becomes 'activated'
        XCTAssertEqual(sut.state, .expired)
    }
    
    func testState_WhenUserIsAuthenticatedAndAccountIsExpiredAndLogsOut() {
        // GIVEN that the user is authenticated
        fixture.accountProvierMock.isLoggedIn = true
        fixture.stubUserAuthenticationStatusMonitor(status: .loggedIn)
        // AND GIVEN that the Onboarding Vpn Profile is installed
        stubOnboardingVpnInstallation(finished: true)
        // AND GIVEN user account is expired
        fixture.accountProvierMock.isExpired = true
        
        instantiateSut()
        
        XCTAssertEqual(sut.state, .expired)
        fixture.accountProvierMock.isLoggedIn = false
        
        // WHEN user logs out
        fixture.userAuthenticationStatusMonitorMock.status.send(.loggedOut)
        
        // THEN the state becomes 'NotActivated'
        XCTAssertEqual(sut.state, .notActivated)
    }
    
    func testState_WhenUserIsAuthenticatedAndLogsOut() {
        // GIVEN that the user is authenticated
        fixture.accountProvierMock.isLoggedIn = true
        fixture.stubUserAuthenticationStatusMonitor(status: .loggedIn)
        // AND GIVEN that the Onboarding Vpn Profile is installed
        stubOnboardingVpnInstallation(finished: true)
        
        instantiateSut()
        
        XCTAssertEqual(sut.state, .activated)
        fixture.accountProvierMock.isLoggedIn = false
        
        // WHEN user logs out
        fixture.userAuthenticationStatusMonitorMock.status.send(.loggedOut)
        
        // THEN the state becomes 'NotActivated'
        XCTAssertEqual(sut.state, .notActivated)
    }
    
    func test_sceneDidBecomeActive_when_authenticated() async {
        // GIVEN that the user is authenticated
        fixture.accountProvierMock.isLoggedIn = true
        fixture.stubUserAuthenticationStatusMonitor(status: .loggedIn)
        // AND GIVEN that the Onboarding Vpn Profile is installed
        stubOnboardingVpnInstallation(finished: true)
        
        instantiateSut()
        XCTAssertFalse(fixture.refreshLatencyUseCaseMock.callAsFunctionCalled)
        
        // WHEN the app scene becomes active
        await sut.sceneDidBecomeActive()
        // THEN the use case to refresh the servers latency is called once
        XCTAssertTrue(fixture.refreshLatencyUseCaseMock.callAsFunctionCalled)
        XCTAssertEqual(fixture.refreshLatencyUseCaseMock.callAsFunctionCalledAttempt, 1)
    }
    
    func test_sceneDidBecomeActive_when_authenticatedNotOnboarded() async {
        // GIVEN that the user is authenticated
        fixture.accountProvierMock.isLoggedIn = true
        fixture.stubUserAuthenticationStatusMonitor(status: .loggedIn)
        // AND GIVEN that the Onboarding Vpn Profile is not installed
        stubOnboardingVpnInstallation(finished: false)
        
        instantiateSut()
        XCTAssertFalse(fixture.refreshLatencyUseCaseMock.callAsFunctionCalled)
        
        // WHEN the app scene becomes active
        await sut.sceneDidBecomeActive()
        
        // THEN the use case to refresh the servers latency is called once
        XCTAssertTrue(fixture.refreshLatencyUseCaseMock.callAsFunctionCalled)
        XCTAssertEqual(fixture.refreshLatencyUseCaseMock.callAsFunctionCalledAttempt, 1)
        
    }
    
    func test_sceneDidBecomeActive_when_notAuthenticated() async {
        // GIVEN that the user is NOT authenticated
        fixture.accountProvierMock.isLoggedIn = false
        fixture.stubUserAuthenticationStatusMonitor(status: .loggedOut)
        // AND GIVEN that the Onboarding Vpn Profile is not installed
        stubOnboardingVpnInstallation(finished: false)
        
        instantiateSut()
        XCTAssertFalse(fixture.refreshLatencyUseCaseMock.callAsFunctionCalled)
        
        // WHEN the app scene becomes active
        await sut.sceneDidBecomeActive()
        
        // THEN the use case to refresh the servers latency is NOT called
        XCTAssertFalse(fixture.refreshLatencyUseCaseMock.callAsFunctionCalled)
        XCTAssertEqual(fixture.refreshLatencyUseCaseMock.callAsFunctionCalledAttempt, 0)
        
    }
    
    func test_sceneDidBecomeInactive() {
        // GIVEN that the Onboarding Vpn Profile is installed
        stubOnboardingVpnInstallation(finished: true)
        
        instantiateSut()
        XCTAssertFalse(fixture.refreshLatencyUseCaseMock.stopCalled)
        
        // WHEN the app scene becomes inactive
        sut.sceneDidBecomeInActive()
        
        // THEN the refresh latency use case is called to stop
        XCTAssertTrue(fixture.refreshLatencyUseCaseMock.stopCalled)
        XCTAssertEqual(fixture.refreshLatencyUseCaseMock.stopCalledAttempt, 1)
    }
}


extension RootContainerViewModelTests {
    private func stubOnboardingVpnInstallation(finished: Bool) {
        fixture.vpnConfigurationAvailabilityMock = VPNConfigurationAvailabilityMock(value: finished)
    }
    
    private func stubConnectionStatsPermisson(value: Bool) {
        fixture.connectionStatsPermissonMock = ConnectionStatsPermissonMock(value: value)
    }
    
}
