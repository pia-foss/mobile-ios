//
//  SignupEmailIntegrationTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 09/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary
import Combine

final class SignupEmailIntegrationTests: XCTestCase {
    var sut: SignupEmailViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedLoadingState: [Bool]!
    var capturedUserAccount: PIA_VPN_tvOS.UserAccount?
    
    func instantiateSut(accountProviderResult: (PIALibrary.UserAccount?, Error?), onSuccessAction: @escaping (PIA_VPN_tvOS.UserAccount) -> Void) {
        let accountProviderMock = AccountProviderMock(userResult: accountProviderResult.0,
                                                      errorResult: accountProviderResult.1,
                                                      appStoreInformationResult: nil)
        
        let signupProvider = SignupProvider(accountProvider: accountProviderMock,
                                            userAccountMapper: UserAccountMapper(),
                                            store: InAppProviderSpy(),
                                            errorMapper: SignupDomainErrorMapper())
        
        let signupUseCase = SignupUseCase(signupProvider: signupProvider)
        sut = SignupEmailViewModel(signupUseCase: signupUseCase,
                                   transaction: InAppTransactionMock.makeStub(),
                                   onSuccessAction: onSuccessAction)
    }
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        capturedLoadingState = []
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        capturedLoadingState = nil
        capturedUserAccount = nil
    }

    func test_signup_succeeds_when_a_valid_userAccount_is_retrieved() throws {
        // GIVEN there is no error on account creation and user account has been created
        let userAccountStub = PIALibrary.UserAccount.makeStub()
        let error: Error? = nil
        let expectation = expectation(description: "Waiting for signup to update")
        
        instantiateSut(accountProviderResult: (userAccountStub, error)) { [weak self] userAccount in
            self?.capturedUserAccount = userAccount
            expectation.fulfill()
        }
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN signup is executed with a valid email
        sut.signup(email: "anEmail@email.com")
        
        // THEN an expected userAccount is captured
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedUserAccount?.credentials.username, userAccountStub.credentials.username)
        XCTAssertEqual(capturedUserAccount?.credentials.password, userAccountStub.credentials.password)
        XCTAssertEqual(capturedUserAccount?.info?.email, userAccountStub.info?.email)
        XCTAssertEqual(capturedUserAccount?.info?.username, userAccountStub.info?.username)
        XCTAssertEqual(capturedUserAccount?.info?.plan, userAccountStub.info?.plan)
        XCTAssertEqual(capturedUserAccount?.info?.productId, userAccountStub.info?.productId)
        XCTAssertEqual(capturedUserAccount?.info?.isRenewable, userAccountStub.info?.isRenewable)
        XCTAssertEqual(capturedUserAccount?.info?.isRecurring, userAccountStub.info?.isRecurring)
        XCTAssertEqual(capturedUserAccount?.info?.expirationDate, userAccountStub.info?.expirationDate)
        XCTAssertEqual(capturedUserAccount?.info?.canInvite, userAccountStub.info?.canInvite)
        XCTAssertEqual(capturedUserAccount?.info?.isExpired, userAccountStub.info?.isExpired)
        XCTAssertEqual(capturedUserAccount?.info?.dateComponentsBeforeExpiration, userAccountStub.info?.dateComponentsBeforeExpiration)
        XCTAssertEqual(capturedUserAccount?.info?.shouldPresentExpirationAlert, userAccountStub.info?.shouldPresentExpirationAlert)
        XCTAssertEqual(capturedUserAccount?.info?.renewUrl, userAccountStub.info?.renewUrl)
        XCTAssertEqual(capturedLoadingState, [true, false])
    
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_signup_shows_an_invalid_email_error_when_the_email_is_not_valid() throws {
        // GIVEN there is no error on account creation
        let error: Error? = nil
        let expectation = expectation(description: "Waiting for signup to update")
        
        instantiateSut(accountProviderResult: (PIALibrary.UserAccount.makeStub(), error)) { [weak self] userAccount in
            self?.capturedUserAccount = userAccount
            expectation.fulfill()
        }
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN signup is executed with a valid email
        sut.signup(email: "anEmail@emai")
        
        // THEN an invalid email error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedUserAccount)
        
        XCTAssertEqual(capturedLoadingState, [])
    
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, Validator.EmailValidationError.emailIsInvalid.errorMessage)
    }
    
    func test_signup_shows_a_generic_error_when_there_is_no_error_and_no_userAccount() throws {
        // GIVEN there is no error on account creation and no user account has been created
        let userAccountStub: PIALibrary.UserAccount? = nil
        let error: Error? = nil
        let expectation = expectation(description: "Waiting for signup to update")
        
        instantiateSut(accountProviderResult: (userAccountStub, error)) { [weak self] userAccount in
            self?.capturedUserAccount = userAccount
            expectation.fulfill()
        }
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN signup is executed with a valid email
        sut.signup(email: "anEmail@email.com")
        
        // THEN a generic error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedUserAccount)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
    
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, L10n.Localizable.Tvos.Signup.Email.Error.Message.generic)
    }
    
    func test_signup_shows_a_generic_error_when_there_is_an_error_when_creating_the_account() throws {
        // GIVEN there is an error on account creation
        let userAccountStub: PIALibrary.UserAccount? = nil
        let expectation = expectation(description: "Waiting for signup to update")
        
        instantiateSut(accountProviderResult: (userAccountStub, ClientError.unexpectedReply)) { [weak self] userAccount in
            self?.capturedUserAccount = userAccount
            expectation.fulfill()
        }
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN signup is executed with a valid email
        sut.signup(email: "anEmail@email.com")
        
        // THEN a generic error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedUserAccount)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
    
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, L10n.Localizable.Tvos.Signup.Email.Error.Message.generic)
    }

}
