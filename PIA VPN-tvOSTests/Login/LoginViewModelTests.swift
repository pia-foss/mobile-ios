//
//  LoginViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 23/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
@testable import PIA_VPN_tvOS

final class LoginViewModelTests: XCTestCase {
    
    func test_login_fails_when_checkAvailability_returns_failure() {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .failure(.throttled(retryAfter: 20))
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for shouldShowErrorMessage property to be updated")
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        var capturedLoginStatuses = [LoginStatus]()
        
        sut.$loginStatus.dropFirst().sink(receiveValue: { status in
            capturedLoginStatuses.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { status in
            XCTAssertTrue(status)
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.login(username: "username", password: "password")
        
        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(sut.isAccountExpired)
        XCTAssertFalse(sut.didLoginSuccessfully)
        XCTAssertEqual(capturedLoginStatuses.count, 1)
        XCTAssertEqual(capturedLoginStatuses[0], LoginStatus.failed(errorMessage: "Too many failed login attempts with this username. Please try again after 20.0 second(s).", field: .none))
    }
    
    func test_login_fails_when_username_is_invalid() {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for shouldShowErrorMessage property to be updated")
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        var capturedLoginStatuses = [LoginStatus]()
        
        sut.$loginStatus.dropFirst().sink(receiveValue: { status in
            capturedLoginStatuses.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { status in
            XCTAssertTrue(status)
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.login(username: "", password: "password")
        
        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(sut.isAccountExpired)
        XCTAssertFalse(sut.didLoginSuccessfully)
        XCTAssertEqual(capturedLoginStatuses.count, 1)
        XCTAssertEqual(capturedLoginStatuses[0], LoginStatus.failed(errorMessage: "You must enter a username and password.", field: .username))
    }
    
    func test_login_fails_when_password_is_invalid() {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for shouldShowErrorMessage property to be updated")
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        var capturedLoginStatuses = [LoginStatus]()
        
        sut.$loginStatus.dropFirst().sink(receiveValue: { status in
            capturedLoginStatuses.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { status in
            XCTAssertTrue(status)
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.login(username: "username", password: "")
        
        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(sut.isAccountExpired)
        XCTAssertFalse(sut.didLoginSuccessfully)
        XCTAssertEqual(capturedLoginStatuses.count, 1)
        XCTAssertEqual(capturedLoginStatuses[0], LoginStatus.failed(errorMessage: "You must enter a username and password.", field: .password))
    }
    
    
    func test_login_succeeds_when_loginUseCase_completes_with_success() {
        // GIVEN
        let userAccount = UserAccount.makeStub()
        let resultLoginUseCase: Result<UserAccount, LoginError> = .success(userAccount)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for didLoginSuccessfully property to be updated")
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        var capturedLoginStatuses = [LoginStatus]()
        
        sut.$loginStatus.dropFirst().sink(receiveValue: { status in
            capturedLoginStatuses.append(status)
        }).store(in: &cancellables)
        
        sut.$didLoginSuccessfully.dropFirst().sink(receiveValue: { status in
            XCTAssertTrue(status)
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.login(username: "username", password: "password")
        
        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertFalse(sut.isAccountExpired)
        XCTAssertEqual(capturedLoginStatuses.count, 2)
        XCTAssertEqual(capturedLoginStatuses[0], LoginStatus.isLogging)
        XCTAssertEqual(capturedLoginStatuses[1], LoginStatus.succeeded(userAccount: userAccount))
    }
    
    func test_login_fails_when_loginUseCase_completes_with_expired_error() {
        // GIVEN
        let resultLoginUseCase: Result<UserAccount, LoginError> = .failure(.expired)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for isAccountExpired property to be updated")
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        var capturedLoginStatuses = [LoginStatus]()
        
        sut.$loginStatus.dropFirst().sink(receiveValue: { status in
            capturedLoginStatuses.append(status)
        }).store(in: &cancellables)
        
        sut.$isAccountExpired.dropFirst().sink(receiveValue: { status in
            XCTAssertTrue(status)
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.login(username: "username", password: "password")
        
        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertFalse(sut.didLoginSuccessfully)
        XCTAssertEqual(capturedLoginStatuses.count, 2)
        XCTAssertEqual(capturedLoginStatuses[0], LoginStatus.isLogging)
        XCTAssertEqual(capturedLoginStatuses[1], LoginStatus.failed(errorMessage: nil, field: .none))
    }
    
    func test_login_fails_when_loginUseCase_completes_with_unauthorized_error() {
        // GIVEN
        let resultLoginUseCase: Result<UserAccount, LoginError> = .failure(.unauthorized)
        let loginWithCredentialsUseCaseMock = LoginWithCredentialsUseCaseMock(result: resultLoginUseCase)
        
        let resultCheckLoginAvailability: Result<Void, LoginError> = .success(())
        let checkLoginAvailabilityMock = CheckLoginAvailabilityMock(result: resultCheckLoginAvailability)
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCaseMock,
                                 checkLoginAvailability: checkLoginAvailabilityMock,
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for shouldShowErrorMessage property to be updated")
        XCTAssertEqual(sut.loginStatus, LoginStatus.none)
        
        var capturedLoginStatuses = [LoginStatus]()
        
        sut.$loginStatus.dropFirst().sink(receiveValue: { status in
            capturedLoginStatuses.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { status in
            XCTAssertTrue(status)
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.login(username: "username", password: "password")
        
        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(sut.isAccountExpired)
        XCTAssertFalse(sut.didLoginSuccessfully)
        XCTAssertEqual(capturedLoginStatuses.count, 2)
        XCTAssertEqual(capturedLoginStatuses[0], LoginStatus.isLogging)
        XCTAssertEqual(capturedLoginStatuses[1], LoginStatus.failed(errorMessage: "Your username or password is incorrect.", field: .none))
    }
}
