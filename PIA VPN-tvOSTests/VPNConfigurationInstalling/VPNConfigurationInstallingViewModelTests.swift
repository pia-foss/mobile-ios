//
//  VPNConfigurationInstallingViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
@testable import PIA_VPN_tvOS

final class VPNConfigurationInstallingViewModelTests: XCTestCase {
    
    final class Fixture {
        let errorMapper = VPNConfigurationInstallingErrorMapper()
        let appRouterSpy = AppRouterSpy()
        
        func makeInstallVPNConfiguration(error: InstallVPNConfigurationError?) -> InstallVPNConfigurationUseCaseType {
            return InstallVPNConfigurationUseCaseMock(error: error)
        }
    }
    
    var fixture: Fixture!
    var sut: VPNConfigurationInstallingViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        fixture = nil
        cancellables = nil
    }

    func test_install_fails_when_installVPNConfiguration_fails() {
        // GIVEN
        sut = VPNConfigurationInstallingViewModel(
            installVPNConfiguration: fixture.makeInstallVPNConfiguration(error: .userCanceled),
            errorMapper: fixture.errorMapper,
            appRouter: fixture.appRouterSpy,
            successDestination: OnboardingDestinations.dashboard)
        
        let expectation = expectation(description: "Waiting for installing to finish with error message")
        let expectedErrorMessage = "We need this permission for the application to function."
        
        var capturedInstallingStatuses = [VPNConfigurationInstallingStatus]()
        
        sut.$installingStatus.dropFirst().sink(receiveValue: { status in
            capturedInstallingStatuses.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.install()

        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(capturedInstallingStatuses, [.isInstalling, .failed(errorMessage: expectedErrorMessage)])
        XCTAssert(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, expectedErrorMessage)
        XCTAssertEqual(fixture.appRouterSpy.requests, [])
    }
    
    func test_install_succeeds_when_installVPNConfiguration_succeeds() {
        // GIVEN
        sut = VPNConfigurationInstallingViewModel(
            installVPNConfiguration: fixture.makeInstallVPNConfiguration(error: nil),
            errorMapper: fixture.errorMapper,
            appRouter: fixture.appRouterSpy,
            successDestination: OnboardingDestinations.dashboard)
        
        let expectation = expectation(description: "Waiting for installing to finish successfully")
        var capturedInstallingStatuses = [VPNConfigurationInstallingStatus]()
        
        sut.$installingStatus.dropFirst().sink(receiveValue: { status in
            capturedInstallingStatuses.append(status)
        }).store(in: &cancellables)
        
        fixture.appRouterSpy.didGetARequest = { expectation.fulfill() }
        
        // WHEN
        sut.install()

        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(capturedInstallingStatuses, [.isInstalling, .succeeded])
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(fixture.appRouterSpy.requests, [.navigate(OnboardingDestinations.dashboard)])
    }
}
