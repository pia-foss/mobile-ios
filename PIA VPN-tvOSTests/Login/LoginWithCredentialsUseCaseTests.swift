//
//  LoginWithCredentialsUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN_tvOS

final class LoginWithCredentialsUseCaseTests: XCTestCase {

    func test_login_succeeds_when_loginprovider_completes_with_user_and_no_error() throws {
        // GIVEN
        let user = UserAccount.makeStub()
        let loginProviderMock = LoginProviderMock(userResult: user, errorResult: nil)
        let sut = LoginWithCredentialsUseCase(loginProvider: loginProviderMock,
                                              errorMapper: LoginDomainErrorMapper())
        
        var capturedResult: Result<UserAccount, LoginError>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.execute(username: "", password: "") { result in
            expectation.fulfill()
            capturedResult = result
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedResult, .success(user))
    }
    
    func test_login_fails_when_loginprovider_completes_with_user_and_error() throws {
        // GIVEN
        let user = UserAccount.makeStub()
        let loginProviderMock = LoginProviderMock(userResult: user, errorResult: ClientError.expired)
        let sut = LoginWithCredentialsUseCase(loginProvider: loginProviderMock,
                                              errorMapper: LoginDomainErrorMapper())
        
        var capturedResult: Result<UserAccount, LoginError>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.execute(username: "", password: "") { result in
            expectation.fulfill()
            capturedResult = result
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedResult, .failure(.expired))
    }
    
    func test_login_fails_when_loginprovider_completes_with_no_user_and_error() throws {
        // GIVEN
        let loginProviderMock = LoginProviderMock(userResult: nil, errorResult: ClientError.expired)
        let sut = LoginWithCredentialsUseCase(loginProvider: loginProviderMock,
                                              errorMapper: LoginDomainErrorMapper())
        
        var capturedResult: Result<UserAccount, LoginError>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.execute(username: "", password: "") { result in
            expectation.fulfill()
            capturedResult = result
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedResult, .failure(.expired))
    }
    
    func test_login_fails_when_loginprovider_completes_with_no_user_and_no_error() throws {
        // GIVEN
        let loginProviderMock = LoginProviderMock(userResult: nil, errorResult: nil)
        let sut = LoginWithCredentialsUseCase(loginProvider: loginProviderMock,
                                              errorMapper: LoginDomainErrorMapper())
        
        var capturedResult: Result<UserAccount, LoginError>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.execute(username: "", password: "") { result in
            expectation.fulfill()
            capturedResult = result
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        guard case LoginError.generic = error else {
            XCTFail("Expected generic error, got \(error)")
            return
        }
    }
}
