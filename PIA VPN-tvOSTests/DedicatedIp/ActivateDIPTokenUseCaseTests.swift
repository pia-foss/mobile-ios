//
//  ActivateDIPTokenUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class ActivateDIPTokenUseCaseTests: XCTestCase {
    class Fixture {
        var dipServerProviderMock: DedicatedIPProviderMock!
    }
    
    var fixture: Fixture!
    var sut: ActivateDIPTokenUseCase!
    
    func instantiateSut(result: Result<Void, DedicatedIPError>) {
        fixture.dipServerProviderMock = DedicatedIPProviderMock(result: result)
        sut = ActivateDIPTokenUseCase(dipServerProvider: fixture.dipServerProviderMock)
    }

    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }

    func test_activatesDIPToken_complets_successfully_when_DedicatedIPProvider_complets_with_success() async {
        // GIVEN
        instantiateSut(result: .success(()))
        
        // WHEN
        do {
            try await sut(token: "token")
        } catch {
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func test_activatesDIPToken_complets_with_failure_when_DedicatedIPProvider_complets_with_failure() async throws {
        // GIVEN
        let expectedError = DedicatedIPError.expired
        instantiateSut(result: .failure(expectedError))
        
        var capturedError: Error?
        
        // WHEN
        do {
            try await sut(token: "token")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? DedicatedIPError)
        XCTAssertEqual(error, expectedError)
    }
}

extension DedicatedIPError: Equatable {
    public static func == (lhs: PIA_VPN_tvOS.DedicatedIPError, rhs: PIA_VPN_tvOS.DedicatedIPError) -> Bool {
        switch (lhs, rhs) {
            case (.expired, .expired), (.invalid, .invalid), (.generic, .generic):
                return true
            default: 
                return false
        }
    }
}
