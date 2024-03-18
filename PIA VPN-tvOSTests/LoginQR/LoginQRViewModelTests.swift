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
    }
    
    var fixture: Fixture!
    var sut: LoginQRViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedState: [LoginQRViewModel.State]!
    
    func instantiateSut(generateLoginQRResult: Result<LoginQRCode, ClientError>, validateLoginQRError: ClientError?, onSuccessAction: @escaping () -> Void, onNavigateAction: @escaping () -> Void) {
        
        
        fixture.generateLoginQRCodeMock = GenerateLoginQRCodeUseCaseMock(result: generateLoginQRResult)
        fixture.validateLoginQRCodeMock = ValidateLoginQRCodeMock(error: validateLoginQRError)
        
        sut = LoginQRViewModel(generateLoginQRCode: fixture.generateLoginQRCodeMock,
                               validateLoginQRCode: fixture.validateLoginQRCodeMock,
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
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(100))
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
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(100))
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
        let loginQRCode = LoginQRCode(token: "token", expiresAt: Date().addingTimeInterval(100))
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
}
