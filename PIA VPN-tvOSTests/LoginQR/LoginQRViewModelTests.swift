//
//  LoginQRViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
import PIALibrary
@testable import PIA_VPN_tvOS

final class LoginQRViewModelTests: XCTestCase {
    class Fixture {
        var generateLoginQRCodeMock: GenerateLoginQRCodeUseCaseMock!
        var validateLoginQRCodeMock: ValidateLoginQRCodeMock!
        var loginWithReceiptMock: LoginWithReceiptUseCaseMock!
    }
    
    var fixture: Fixture!
    var sut: LoginQRViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedState: [LoginQRViewModel.State]!
    
    func instantiateSut(generateLoginQRResult: Result<LoginQRCode, ClientError>, validateLoginQRError: ClientError?, loginWithReceiptResult: Result<PIA_VPN_tvOS.UserAccount, Error> = .failure(LoginError.unauthorized), onSuccessAction: @escaping () -> Void, onNavigateAction: @escaping () -> Void) {
        
        fixture.generateLoginQRCodeMock = GenerateLoginQRCodeUseCaseMock(result: generateLoginQRResult)
        fixture.validateLoginQRCodeMock = ValidateLoginQRCodeMock(error: validateLoginQRError)
        fixture.loginWithReceiptMock = LoginWithReceiptUseCaseMock(result: loginWithReceiptResult)
        
        sut = LoginQRViewModel(generateLoginQRCode: fixture.generateLoginQRCodeMock,
                               validateLoginQRCode: fixture.validateLoginQRCodeMock, 
                               loginWithReceipt: fixture.loginWithReceiptMock,
                               onSuccessAction: onSuccessAction,
                               onNavigateAction: onNavigateAction)
    }
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
        capturedState = []
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedState = nil
    }
    
    func test_generateQRCode_succeeds_when_it_generates_a_token_and_its_validated() {
        // GIVEN
        let expectation = expectation(description: "Waiting for onSuccessAction")
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(1000))
        instantiateSut(generateLoginQRResult: .success(loginQRCode),
                       validateLoginQRError: nil,
                       onSuccessAction: {
            expectation.fulfill()
        },
                       onNavigateAction: {
            XCTFail("onNavigateAction was not expected")
        })
        
        sut.$state.dropFirst().sink(receiveValue: { [weak self] status in
            self?.capturedState.append(status)
        }).store(in: &cancellables)
        
        // WHEN
        sut.generateQRCode()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.qrCodeURL, loginQRCode.url)
        XCTAssertEqual(capturedState, [.loading, .validating])
        XCTAssertFalse(sut.shouldShowErrorMessage)
    }
    
    func test_generateQRCode_fails_when_it_generates_a_token() {
        // GIVEN
        let expectation = expectation(description: "Waiting for onSuccessAction")
        instantiateSut(generateLoginQRResult: .failure(ClientError.malformedResponseData),
                       validateLoginQRError: nil,
                       onSuccessAction: {
            XCTFail("onSuccessAction was not expected")
        },
                       onNavigateAction: {
            XCTFail("onNavigateAction was not expected")
        })
        
        sut.$state.dropFirst().sink(receiveValue: { [weak self] status in
            self?.capturedState.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.generateQRCode()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(sut.qrCodeURL)
        XCTAssertEqual(capturedState, [.loading, .validating])
        XCTAssertTrue(sut.shouldShowErrorMessage)
    }
    
    func test_generateQRCode_fails_when_it_generates_a_token_and_its_not_validated() {
        // GIVEN
        let expectation = expectation(description: "Waiting for onSuccessAction")
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(1000))
        instantiateSut(generateLoginQRResult: .success(loginQRCode),
                       validateLoginQRError: ClientError.malformedResponseData,
                       onSuccessAction: {
            XCTFail("onSuccessAction was not expected")
        },
                       onNavigateAction: {
            XCTFail("onNavigateAction was not expected")
        })
        
        sut.$state.dropFirst().sink(receiveValue: { [weak self] status in
            self?.capturedState.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.generateQRCode()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.qrCodeURL, loginQRCode.url)
        XCTAssertEqual(capturedState, [.loading, .validating, .expired])
        XCTAssertTrue(sut.shouldShowErrorMessage)
    }
    
    func test_navigateToRoute_succeeds() {
        // GIVEN
        let expectation = expectation(description: "Waiting for onSuccessAction")
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(1000))
        instantiateSut(generateLoginQRResult: .success(loginQRCode),
                       validateLoginQRError: ClientError.malformedResponseData,
                       onSuccessAction: {
            XCTFail("onSuccessAction was not expected")
        },
                       onNavigateAction: {
            expectation.fulfill()
        })
        
        // WHEN
        sut.navigateToRoute()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_recoverPurchases_succeeds_when_there_is_a_valid_purchase() {
        // GIVEN
        let expectation = expectation(description: "Waiting for onSuccessAction")
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(1000))
        instantiateSut(generateLoginQRResult: .success(loginQRCode),
                       validateLoginQRError: nil,
                       loginWithReceiptResult: .success(UserAccount.makeStub()),
                       onSuccessAction: {
            expectation.fulfill()
        },
                       onNavigateAction: {
            XCTFail("onNavigateAction was not expected")
        })
        
        sut.$state.dropFirst().sink(receiveValue: { [weak self] status in
            self?.capturedState.append(status)
        }).store(in: &cancellables)
        
        // WHEN
        sut.recoverPurchases()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedState, [.loading])
        XCTAssertFalse(sut.shouldShowErrorMessage)
    }
    
    func test_recoverPurchases_fails_when_there_is_no_valid_purchase() {
        // GIVEN
        let expectation = expectation(description: "Waiting for onSuccessAction")
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(100))
        instantiateSut(generateLoginQRResult: .failure(ClientError.malformedResponseData),
                       validateLoginQRError: nil,
                       onSuccessAction: {
            XCTFail("onSuccessAction was not expected")
        },
                       onNavigateAction: {
            XCTFail("onNavigateAction was not expected")
        })
        
        sut.$state.dropFirst().sink(receiveValue: { [weak self] status in
            self?.capturedState.append(status)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.recoverPurchases()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedState, [.loading, .validating])
        XCTAssertTrue(sut.shouldShowErrorMessage)
    }
}
