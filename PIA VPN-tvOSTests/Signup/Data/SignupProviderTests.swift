//
//  SignupProviderTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN_tvOS

final class SignupProviderTests: XCTestCase {
    class Fixture {
        var accountProviderMock: AccountProviderMock!
        var storeSpy: InAppProviderSpy = InAppProviderSpy()
    }
    
    var fixture: Fixture!
    var sut: SignupProvider!
    var capturedResult: Result<PIA_VPN_tvOS.UserAccount, SignupError>?
    
    func instantiateSut(accountProviderResult: (PIALibrary.UserAccount?, Error?)) {
        fixture.accountProviderMock = AccountProviderMock(userResult: accountProviderResult.0, errorResult: accountProviderResult.1)
        sut = SignupProvider(accountProvider: fixture.accountProviderMock,
                             userAccountMapper: UserAccountMapper(),
                             store: fixture.storeSpy, 
                             errorMapper: SignupDomainErrorMapper())
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        capturedResult = nil
    }

    func test_signup_completes_with_success_when_accoutProvider_completes_with_an_userAccount_and_no_error() throws {
        // GIVEN accoutProvider completes with valid userAccount and no error
        let user = PIALibrary.UserAccount.makeStub()
        let error: Error? = nil
        
        instantiateSut(accountProviderResult: (user, error))
        let expectation = expectation(description: "Waiting for listPlanProducts to finish")
        
        
        // WHEN signup is executed
        sut.signup(email: "anEmail", transaction: nil) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN a successful UserAccount is captured
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
    
    func test_signup_completes_with_failure_when_accoutProvider_completes_with_no_userAccount_and_an_error() {
        // GIVEN accoutProvider completes with no userAccount and an error
        let user: PIALibrary.UserAccount? = nil
        let expectedError = NSError(domain: "anError", code: 0)
        
        instantiateSut(accountProviderResult: (user, expectedError))
        let expectation = expectation(description: "Waiting for signup to finish")
        
        // WHEN signup is executed
        sut.signup(email: "anEmail", transaction: nil) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN a error is captured
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        XCTAssertEqual(error, .generic)
    }
    
    func test_signup_completes_with_failure_when_accoutProvider_completes_with_no_userAccount_and_no_error() throws {
        // GIVEN accoutProvider completes with no userAccount and no error
        let user: PIALibrary.UserAccount? = nil
        let expectedError: Error? = nil
        
        instantiateSut(accountProviderResult: (user, expectedError))
        let expectation = expectation(description: "Waiting for signup to finish")
        
        // WHEN signup is executed
        sut.signup(email: "anEmail", transaction: nil) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN a error is captured
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        XCTAssertEqual(error, .generic)
    }
    
    func test_signup_completes_with_failure_when_accoutProvider_completes_with_an_userAccount_and_an_error() {
        // GIVEN accoutProvider completes with valid userAccount and an error
        let user = PIALibrary.UserAccount.makeStub()
        let expectedError = NSError(domain: "anError", code: 0)
        
        instantiateSut(accountProviderResult: (user, expectedError))
        let expectation = expectation(description: "Waiting for signup to finish")
        
        // WHEN signup is executed
        sut.signup(email: "anEmail", transaction: nil) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN a successful UserAccount is captured
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        XCTAssertEqual(error, .generic)
    }
    
    func test_signup_refreshes_payment_when_there_is_no_paymentReceipt() {
        // GIVEN there is no payment receipt
        fixture.storeSpy.paymentReceipt = nil
        let user = PIALibrary.UserAccount.makeStub()
        let error: Error? = nil
        
        instantiateSut(accountProviderResult: (user, error))
        let expectation = expectation(description: "Waiting for signup to finish")
        
        // WHEN signup is executed
        sut.signup(email: "anEmail", transaction: nil) { result in
            expectation.fulfill()
        }
        
        // THEN refreshPaymentReceipt method from storeSpy is called
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(fixture.storeSpy.refreshPaymentReceiptCalledAttempt, 1)
    }
    
    func test_signup_does_not_refresh_payment_when_there_is_a_paymentReceipt() {
        // GIVEN there is no payment receipt
        fixture.storeSpy.paymentReceipt = Data()
        let user = PIALibrary.UserAccount.makeStub()
        let error: Error? = nil
        
        instantiateSut(accountProviderResult: (user, error))
        let expectation = expectation(description: "Waiting for signup to finish")
        
        // WHEN signup is executed
        sut.signup(email: "anEmail", transaction: nil) { result in
            expectation.fulfill()
        }
        
        // THEN refreshPaymentReceipt method from storeSpy is not called
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(fixture.storeSpy.refreshPaymentReceiptCalledAttempt, 0)
    }
}
