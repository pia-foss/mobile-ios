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
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, .none)
        
        // WHEN
        await sut.login(username: "username", password: "password")
        
        // THEN
        guard case .succeeded(let capturedUserResult) = sut.loginStatus else {
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
    
    func test_login_fails() async throws {
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
                                 errorMapper: LoginPresentableErrorMapper())
        
        XCTAssertEqual(sut.loginStatus, .none)
        
        // WHEN
        await sut.login(username: "username", password: "password")
        
        // THEN
        XCTAssertEqual(sut.loginStatus, .failed(error: .expired))
    }
}
