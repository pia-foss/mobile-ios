//
//  LoginViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 23/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class LoginViewModelTests: XCTestCase {
    
    func test_login_fails_when_checkAvailability_returns_failure() async throws {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .failure(.throttled(retryAfter: 20))
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        // WHEN
        await sut.login(username: "username", password: "password")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, LoginStatus.failed(error: .throttled(retryAfter: 20)))
    }
    
    func test_login_fails_when_username_is_invalid() async throws {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        // WHEN
        await sut.login(username: "", password: "password")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, LoginStatus.failed(error: .usernameWrongFormat))
    }
    
    func test_login_fails_when_password_is_invalid() async throws {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        // WHEN
        await sut.login(username: "username", password: "")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, LoginStatus.failed(error: .passwordWrongFormat))
    }
    
    
    func test_login_succeeds_when_loginUseCase_completes_with_success() async throws {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        // WHEN
        await sut.login(username: "username", password: "password")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, LoginStatus.succeeded(userAccount: userAccount))
    }
    
    func test_login_fails_when_loginUseCase_completes_with_failure() async throws {
        // GIVEN
        let resultLoginUseCase: Result<UserAccount, LoginError> = .failure(.unauthorized)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        // WHEN
        await sut.login(username: "username", password: "password")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, LoginStatus.failed(error: .unauthorized))
    }
}
