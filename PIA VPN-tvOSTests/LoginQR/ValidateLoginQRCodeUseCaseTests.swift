//
//  ValidateLoginQRCodeUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN_tvOS

final class ValidateLoginQRCodeUseCaseTests: XCTestCase {
    class Fixture {
        var accountProviderMock: AccountProviderMock!
        var validateLoginQRCodeProviderMock: ValidateLoginQRCodeProviderMock!
    }
    
    var fixture: Fixture!
    var sut: ValidateLoginQRCodeUseCase!
    
    func instantiateSut(userResult: PIALibrary.UserAccount?, errorResult: Error?, validateLoginQRCodeResult: Result<UserToken, LoginQRCodeError>) {
        fixture.accountProviderMock = AccountProviderMock(userResult: userResult, errorResult: errorResult)
        fixture.validateLoginQRCodeProviderMock = ValidateLoginQRCodeProviderMock(result: validateLoginQRCodeResult)
        
        sut = ValidateLoginQRCodeUseCase(accountProviderType: fixture.accountProviderMock,
                                         validateLoginQRCodeProvider: fixture.validateLoginQRCodeProviderMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    func test_callAsFunction_succeeds_when_validateLoginQRCodeProvider_and_accountProvider_succeeds() async {
        // GIVEN
        let userAccount = PIALibrary.UserAccount(credentials: PIALibrary.Credentials(username: "", password: ""), info: nil)
        let userToken = UserToken(token: "token",
                                  expiresAt: Date.makeISO8601Date(string: "2024-03-15T16:43:24Z")!,
                                  userId: "userId")
        let qrCodeToken = LoginQRCode(token: "token", expiresAt: Date.makeISO8601Date(string: "2024-03-15T16:43:24Z")!)
        
        instantiateSut(userResult: userAccount,
                       errorResult: nil,
                       validateLoginQRCodeResult: .success(userToken))
        
        // WHEN
        do {
            try await sut(qrCodeToken: qrCodeToken)
        } catch {
            XCTFail("Expected success, got error \(error)")
        }
    }
    
    func test_callAsFunction_fails_when_validateLoginQRCodeProvider_returns_an_error() async throws {
        // GIVEN
        let userAccount = PIALibrary.UserAccount(credentials: PIALibrary.Credentials(username: "", password: ""), info: nil)
        let qrCodeToken = LoginQRCode(token: "token", expiresAt: Date.makeISO8601Date(string: "2024-03-15T16:43:24Z")!)
        
        instantiateSut(userResult: userAccount,
                       errorResult: nil,
                       validateLoginQRCodeResult: .failure(LoginQRCodeError.generic))
        
        var capturedError: Error?
        
        // WHEN
        do {
            try await sut(qrCodeToken: qrCodeToken)
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? LoginQRCodeError)
        XCTAssertEqual(error, .generic)
    }
    
    func test_callAsFunction_fails_when_accountProvider_returns_an_error() async throws {
        // GIVEN
        let userToken = UserToken(token: "token",
                                  expiresAt: Date.makeISO8601Date(string: "2024-03-15T16:43:24Z")!,
                                  userId: "userId")
        let qrCodeToken = LoginQRCode(token: "token", expiresAt: Date.makeISO8601Date(string: "2024-03-15T16:43:24Z")!)
        
        instantiateSut(userResult: nil,
                       errorResult: LoginQRCodeError.generic,
                       validateLoginQRCodeResult: .success(userToken))
        
        var capturedError: Error?
        
        // WHEN
        do {
            try await sut(qrCodeToken: qrCodeToken)
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? LoginQRCodeError)
        XCTAssertEqual(error, .generic)
    }
}
