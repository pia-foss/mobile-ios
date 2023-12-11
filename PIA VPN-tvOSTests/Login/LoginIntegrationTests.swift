//
//  LoginIntegrationTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 11/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN_tvOS

final class LoginIntegrationTests: XCTestCase {

    func test_login_succeeds() async throws {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let loginProviderMock = LoginProviderMock(userResult: userAccount, errorResult: nil)
        let loginWithCredentialsUseCase = LoginWithCredentialsUseCase(loginProvider: loginProviderMock,
                                    errorMapper: LoginDomainErrorMapper())
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCase,
                                 checkLoginAvailability: CheckLoginAvailability(),
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, .none)
        
        // WHEN
        await sut.login(username: "username", password: "password")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, LoginStatus.succeeded(userAccount: userAccount))
    }
    
    func test_login_fails() async throws {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let loginProviderMock = LoginProviderMock(userResult: userAccount, errorResult: ClientError.expired)
        let loginWithCredentialsUseCase = LoginWithCredentialsUseCase(loginProvider: loginProviderMock,
                                    errorMapper: LoginDomainErrorMapper())
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCase,
                                 checkLoginAvailability: CheckLoginAvailability(),
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, .none)
        
        // WHEN
        await sut.login(username: "username", password: "password")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, .failed(error: .expired))
    }
}
