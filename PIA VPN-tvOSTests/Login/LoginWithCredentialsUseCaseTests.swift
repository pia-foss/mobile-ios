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

    func test_login_succeeds_when_loginprovider_completes_with_success() {
        // GIVEN
        let user = UserAccount.makeStub()
        let loginProviderMock = LoginProviderMock(result: .success(user))
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
    
    func test_login_fails_when_loginprovider_completes_with_failure() {
        // GIVEN
        let loginProviderMock = LoginProviderMock(result: .failure(ClientError.expired))
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
}
