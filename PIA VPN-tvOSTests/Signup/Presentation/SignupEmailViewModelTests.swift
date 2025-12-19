//
//  SignupEmailViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 29/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary
import Combine

final class SignupEmailViewModelTests: XCTestCase {
    class Fixture {
        var signupUseCaseMock: SignupUseCaseMock!
    }
    
    var fixture: Fixture!
    var sut: SignupEmailViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedLoadingState: [Bool]!
    
    func instantiateSut(signupUseCaseResult: Result<PIA_VPN_tvOS.UserAccount, Error>, onSuccessAction: @escaping ((PIA_VPN_tvOS.UserAccount) -> Void)) {
        fixture.signupUseCaseMock = SignupUseCaseMock(result: signupUseCaseResult)
        sut = SignupEmailViewModel(signupUseCase: fixture.signupUseCaseMock,
                                   transaction: nil, 
                                   onSuccessAction: onSuccessAction)
    }
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
        capturedLoadingState = []
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedLoadingState = nil
    }

    func test_signup_executes_onSuccessAction_when_signup_returns_an_userAccount_and_a_valid_email_is_provided() {
        // GIVEN signupUseCase completes with an UserAccount
        let expectedUserAccount = PIA_VPN_tvOS.UserAccount.makeStub()
        let expectation = expectation(description: "Waiting for signup to update")
        var capturedUserAccount: PIA_VPN_tvOS.UserAccount?
        
        instantiateSut(signupUseCaseResult: .success(expectedUserAccount),
                       onSuccessAction: { userAccount in
            capturedUserAccount = userAccount
            expectation.fulfill()
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN signup is executed with a valid email
        sut.signup(email: "anEmail@email.com")
        
        // THEN capturedUserAccount is the provided UserAccount
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedUserAccount, expectedUserAccount)
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.shouldShowErrorMessage)
    }
    
    func test_signup_presents_error_when_and_an_invalid_email_is_provided() {
        // GIVEN signupUseCase completes with an UserAccount
        let expectedUserAccount = PIA_VPN_tvOS.UserAccount.makeStub()
        let expectation = expectation(description: "Waiting for signup to update")
        var capturedUserAccount: PIA_VPN_tvOS.UserAccount?
        
        instantiateSut(signupUseCaseResult: .success(expectedUserAccount),
                       onSuccessAction: { userAccount in
            capturedUserAccount = userAccount
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN signup is executed with an invalid email
        sut.signup(email: "anEmail@email")
        
        // THEN error alert is presented with the text
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedUserAccount)
        XCTAssertEqual(capturedLoadingState, [])
        XCTAssertEqual(sut.errorMessage, Validator.EmailValidationError.emailIsInvalid.errorMessage)
        XCTAssertTrue(sut.shouldShowErrorMessage)
    }
    
    func test_signup_presents_an_error_when_signup_throws_an_error() {
        // GIVEN signupUseCase throws an error
        let expectation = expectation(description: "Waiting for signup to update")
        var capturedUserAccount: PIA_VPN_tvOS.UserAccount?
        
        instantiateSut(signupUseCaseResult: .failure(NSError(domain: "anError", code: 0)),
                       onSuccessAction: { userAccount in
            capturedUserAccount = userAccount
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN signup is executed with an invalid email
        sut.signup(email: "anEmail@email.com")
        
        // THEN error alert is presented with the text
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedUserAccount)
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertEqual(sut.errorMessage, L10n.Localizable.Tvos.Signup.Email.Error.Message.generic)
        XCTAssertTrue(sut.shouldShowErrorMessage)
    }
}
