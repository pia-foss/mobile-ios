//
//  LoginProviderTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN_tvOS

final class LoginProviderTests: XCTestCase {

    func test_login_succeeds_when_accountprovider_completes_with_user_and_no_error() throws {
        // GIVEN
        let user = PIALibrary.UserAccount.makeStub()
        let accountProviderMock = AccountProviderMock(userResult: user,
                                                      errorResult: nil)
        
        let sut = LoginProvider(accountProvider: accountProviderMock,
                                userAccountMapper: UserAccountMapper())
        
        let credentials = PIA_VPN_tvOS.Credentials(username: "", password: "")
        
        var capturedResult: Result<PIA_VPN_tvOS.UserAccount, Error>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.login(with: credentials) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        guard case .success(let capturedUserResult) = capturedResult else {
            XCTFail("Expected success, got failure")
            return
        }
        
        XCTAssertEqual(capturedUserResult.credentials.username, user.credentials.username)
        XCTAssertEqual(capturedUserResult.credentials.password, user.credentials.password)
        XCTAssertEqual(capturedUserResult.isRenewable, user.isRenewable)
        XCTAssertEqual(capturedUserResult.info?.email, user.info?.email)
        XCTAssertEqual(capturedUserResult.info?.username, user.info?.username)
        XCTAssertEqual(capturedUserResult.info?.productId, user.info?.productId)
        XCTAssertEqual(capturedUserResult.info?.isRenewable, user.info?.isRenewable)
        XCTAssertEqual(capturedUserResult.info?.isRecurring, user.info?.isRecurring)
        XCTAssertEqual(capturedUserResult.info?.expirationDate, user.info?.expirationDate)
        XCTAssertEqual(capturedUserResult.info?.canInvite, user.info?.canInvite)
    
        let capturedPlan = try XCTUnwrap(capturedUserResult.info?.plan)
        let userPlan = try XCTUnwrap(user.info?.plan)
        
        switch (capturedPlan, userPlan) {
            case (Plan.monthly, Plan.monthly), (Plan.yearly, Plan.yearly), (Plan.trial, PIALibrary.Plan.trial), (Plan.other, Plan.other):
                XCTAssertTrue(true)
            default:
                XCTFail("Expected the same plan, got \(capturedPlan) and \(userPlan)")
        }
        
    }
    
    func test_login_fails_when_accountprovider_completes_with_user_and_error() throws {
        // GIVEN
        let user = PIALibrary.UserAccount.makeStub()
        let accountProviderMock = AccountProviderMock(userResult: user,
                                                      errorResult: ClientError.expired)
        
        let sut = LoginProvider(accountProvider: accountProviderMock,
                                userAccountMapper: UserAccountMapper())
        
        let credentials = PIA_VPN_tvOS.Credentials(username: "", password: "")
        
        var capturedResult: Result<PIA_VPN_tvOS.UserAccount, Error>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.login(with: credentials) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        guard case ClientError.expired = error else {
            XCTFail("Expected expired error, got \(error)")
            return
        }
    }
    
    func test_login_fails_when_accountprovider_completes_with_expired_user() throws {
        // GIVEN
        let user = PIALibrary.UserAccount.makeExpiredStub()
        let accountProviderMock = AccountProviderMock(userResult: user,
                                                      errorResult: ClientError.expired)
        
        let sut = LoginProvider(accountProvider: accountProviderMock,
                                userAccountMapper: UserAccountMapper())
        
        let credentials = PIA_VPN_tvOS.Credentials(username: "", password: "")
        
        var capturedResult: Result<PIA_VPN_tvOS.UserAccount, Error>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.login(with: credentials) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        guard case ClientError.expired = error else {
            XCTFail("Expected expired error, got \(error)")
            return
        }
    }
    
    func test_login_fails_when_accountprovider_completes_with_no_user_and_error() throws {
        // GIVEN
        let accountProviderMock = AccountProviderMock(userResult: nil,
                                                      errorResult: ClientError.expired)
        
        let sut = LoginProvider(accountProvider: accountProviderMock,
                                userAccountMapper: UserAccountMapper())
        
        let credentials = PIA_VPN_tvOS.Credentials(username: "", password: "")
        
        var capturedResult: Result<PIA_VPN_tvOS.UserAccount, Error>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.login(with: credentials) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        guard case ClientError.expired = error else {
            XCTFail("Expected expired error, got \(error)")
            return
        }
    }
    
    func test_login_fails_when_accountprovider_completes_with_no_user_and_no_error() throws {
        // GIVEN
        let accountProviderMock = AccountProviderMock(userResult: nil,
                                                      errorResult: nil)
        
        let sut = LoginProvider(accountProvider: accountProviderMock,
                                userAccountMapper: UserAccountMapper())
        
        let credentials = PIA_VPN_tvOS.Credentials(username: "", password: "")
        
        var capturedResult: Result<PIA_VPN_tvOS.UserAccount, Error>?
        let expectation = expectation(description: "Waiting for login to finish")
        
        // WHEN
        sut.login(with: credentials) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        guard case ClientError.unexpectedReply = error else {
            XCTFail("Expected unexpectedReply error, got \(error)")
            return
        }
    }
}
