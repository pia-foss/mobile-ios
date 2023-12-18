//
//  LoginIntegrationTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 11/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
import Combine
@testable import PIA_VPN_tvOS

final class LoginIntegrationTests: XCTestCase {

    func test_login_succeeds() throws {
        // GIVEN
        let userAccount = PIALibrary.UserAccount.makeStub()
        let accountProviderMock = AccountProviderMock(userResult: userAccount,
                                                      errorResult: nil)
        
        let loginProvider = LoginProvider(accountProvider: accountProviderMock,
                                          userAccountMapper: UserAccountMapper())
        
        let loginWithCredentialsUseCase = LoginWithCredentialsUseCase(loginProvider: loginProvider,
                                                                      errorMapper: LoginDomainErrorMapper())
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCase,
                                 checkLoginAvailability: CheckLoginAvailability(),
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for didLoginSuccessfully property to be updated")
        XCTAssertEqual(sut.loginStatus, .none)
                                 
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
        
        guard case .succeeded(let capturedUserResult) = capturedLoginStatuses[1] else {
            XCTFail("Expected success, got failure")
            return
        }
        
        XCTAssertEqual(capturedUserResult.credentials.username, userAccount.credentials.username)
        XCTAssertEqual(capturedUserResult.credentials.password, userAccount.credentials.password)
        XCTAssertEqual(capturedUserResult.isRenewable, userAccount.isRenewable)
        XCTAssertEqual(capturedUserResult.info?.email, userAccount.info?.email)
        XCTAssertEqual(capturedUserResult.info?.username, userAccount.info?.username)
        XCTAssertEqual(capturedUserResult.info?.productId, userAccount.info?.productId)
        XCTAssertEqual(capturedUserResult.info?.isRenewable, userAccount.info?.isRenewable)
        XCTAssertEqual(capturedUserResult.info?.isRecurring, userAccount.info?.isRecurring)
        XCTAssertEqual(capturedUserResult.info?.expirationDate, userAccount.info?.expirationDate)
        XCTAssertEqual(capturedUserResult.info?.canInvite, userAccount.info?.canInvite)
    
        let capturedPlan = try XCTUnwrap(capturedUserResult.info?.plan)
        let userPlan = try XCTUnwrap(userAccount.info?.plan)
        
        switch (capturedPlan, userPlan) {
            case (PIA_VPN_tvOS.Plan.monthly, PIALibrary.Plan.monthly), (PIA_VPN_tvOS.Plan.yearly, PIALibrary.Plan.yearly), (PIA_VPN_tvOS.Plan.trial, PIALibrary.Plan.trial), (PIA_VPN_tvOS.Plan.other, PIALibrary.Plan.other):
                XCTAssertTrue(true)
            default:
                XCTFail("Expected the same plan, got \(capturedPlan) and \(userPlan)")
        }
    }
    
    func test_login_fails() {
        // GIVEN
        let accountProviderMock = AccountProviderMock(userResult: nil,
                                                      errorResult: ClientError.expired)
        
        let loginProvider = LoginProvider(accountProvider: accountProviderMock,
                                          userAccountMapper: UserAccountMapper())
        
        let loginWithCredentialsUseCase = LoginWithCredentialsUseCase(loginProvider: loginProvider,
                                    errorMapper: LoginDomainErrorMapper())
        
        let sut = LoginViewModel(loginWithCredentialsUseCase: loginWithCredentialsUseCase,
                                 checkLoginAvailability: CheckLoginAvailability(),
                                 validateLoginCredentials: ValidateCredentialsFormat(),
                                 errorHandler: LoginViewModelErrorHandler(errorMapper: LoginPresentableErrorMapper()))
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "Waiting for isAccountExpired property to be updated")
        XCTAssertEqual(sut.loginStatus, .none)
                                 
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
}
