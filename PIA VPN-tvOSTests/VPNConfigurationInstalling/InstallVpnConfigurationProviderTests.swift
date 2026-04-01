//
//  InstallVpnConfigurationProviderTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/12/23.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class InstallVpnConfigurationProviderTests: XCTestCase {
    
    final class Fixture {
        let vpnConfigurationAvailability = VPNConfigurationAvailabilityMock(value: false)
        
        func makeVpnConfigurationProvider(error: Error?) -> VpnConfigurationProviderType {
            return VpnConfigurationProviderTypeMock(error: error)
        }
    }
    
    var fixture: Fixture!
    var sut: InstallVpnConfigurationProvider!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    func test_install_succeeds_when_vpnprovider_completes_with_success() async {
        // GIVEN
        sut = InstallVpnConfigurationProvider(vpnProvider: fixture.makeVpnConfigurationProvider(error: nil),
                                              vpnConfigurationAvailability: fixture.vpnConfigurationAvailability)
        
        // WHEN
        do {
            try await sut()
        } catch {
            XCTFail("Expected success, got error")
        }
        
        // THEN
        XCTAssertEqual(fixture.vpnConfigurationAvailability.settedValues, [true])
    }
    
    func test_install_fails_when_vpnprovider_completes_with_error() async throws {
        // GIVEN
        let anyError = NSError(domain: "error", code: 0)
        sut = InstallVpnConfigurationProvider(vpnProvider: fixture.makeVpnConfigurationProvider(error: anyError),                                               vpnConfigurationAvailability: fixture.vpnConfigurationAvailability)
        var capturedError: Error?
        
        // WHEN
        do {
            try await sut()
        } catch {
            capturedError = error
        }
        
        // THEN
        let capturedInstallVPNConfigurationError = try XCTUnwrap(capturedError as? InstallVPNConfigurationError)
        XCTAssertEqual(capturedInstallVPNConfigurationError, .userCanceled)
        XCTAssertEqual(fixture.vpnConfigurationAvailability.settedValues, [])
    }
}
