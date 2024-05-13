//
//  SignupUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class SignupUseCaseTests: XCTestCase {
    class Fixture {
        var signupProviderMock: SignupProviderMock!
    }
    
    var fixture: Fixture!
    var sut: SignupUseCase!
    var capturedResult: Result<UserAccount, SignupError>?
    
    func instantiateSut(signupProviderResult: Result<UserAccount, SignupError>) {
        fixture.signupProviderMock = SignupProviderMock(result: signupProviderResult)
        sut = SignupUseCase(signupProvider: fixture.signupProviderMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        capturedResult = nil
    }
    
    func test_signup_returns_an_userAccount_when_signupProvider_completes_with_an_userAccount() async throws {
        // GIVEN signupProvider completes with an userAccount
        let stub = UserAccount.makeStub()
        instantiateSut(signupProviderResult: .success(stub))
        
        // WHEN signup is executed
        let result = try await sut(email: "anEmail", transaction: nil)
        
        // THEN signup returns the provided userAccount
        XCTAssertEqual(result, stub)
    }

    func test_signup_throws_an_error_when_signupProvider_completes_with_an_error() async throws {
        // GIVEN productsProvider completes with an generic error
        instantiateSut(signupProviderResult: .failure(.generic))
        
        do {
            // WHEN signup is executed
            _ = try await sut(email: "anEmail", transaction: nil)
            XCTFail("Expected to throw an error")
        } catch {
            // THEN signup throws an generic error
            let signupError = try XCTUnwrap(error as? SignupError)
            XCTAssertEqual(signupError, .generic)
        }
    }
}
