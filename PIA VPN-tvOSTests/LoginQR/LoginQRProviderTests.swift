//
//  LoginQRProviderTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
import PIALibrary
@testable import PIA_VPN_tvOS

final class LoginQRProviderTests: XCTestCase {
    class Fixture {
        var httpClientMock: HTTPClientMock!
        let urlRequestMaker = LoginQRURLRequestMaker()
        let domainMapper = LoginQRCodeDomainMapper()
        let errorMapper = LoginQRErrorMapper()
        var generateQRLoginUseCaseMock: GenerateQRLoginUseCaseMock!
        var accountProviderMock: AccountProviderMock!
    }
    
    var fixture: Fixture!
    var sut: LoginQRProvider!
    
    func instantiateSut(result: Result<Data, ClientError>, apiToken: String? = nil, accountProviderErrorResult: Error? = nil) {
        fixture.httpClientMock = HTTPClientMock(result: result)
        fixture.generateQRLoginUseCaseMock = GenerateQRLoginUseCaseMock(result: result)
        fixture.accountProviderMock = AccountProviderMock(userResult: nil, errorResult: accountProviderErrorResult)
        fixture.accountProviderMock.apiToken = apiToken
        sut = LoginQRProvider(httpClient: fixture.httpClientMock,
                              urlRequestMaker: fixture.urlRequestMaker,
                              domainMapper: fixture.domainMapper,
                              errorMapper: fixture.errorMapper,
                              generateQRLogin: fixture.generateQRLoginUseCaseMock,
                              accountProvider: fixture.accountProviderMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    func test_generateLoginQRCodeToken_succeeds_when_httpclient_returns_a_valid_json() async {
        // GIVEN
        let data = 
        """
            {
                "login_token":"f1ecc01aff18fe7",
                "expires_at":"2024-03-15T16:43:24Z"
            }
        """.data(using: .utf8)!
        
        instantiateSut(result: .success(data))
        
        var loginToken: LoginQRCode?
        
        // WHEN
        do {
            loginToken = try await sut.generateLoginQRCodeToken()
        } catch {
            XCTFail("Expected success, got error \(error)")
        }
        
        // THEN
        XCTAssertEqual(loginToken?.token, "f1ecc01aff18fe7")
        XCTAssertEqual(loginToken?.url, URL(string: "piavpn:loginqr?token=f1ecc01aff18fe7"))
        XCTAssertEqual(loginToken?.expiresAt, Date.makeISO8601Date(string: "2024-03-15T16:43:24Z"))
    }
    
    func test_generateLoginQRCodeToken_fails_when_httpclient_returns_an_invalid_json() async throws {
        // GIVEN
        let data =
        """
            {
                "logintoken":"f1ecc01aff18fe7",
                "expiresat":"2024-03-15T16:43:24Z"
            }
        """.data(using: .utf8)!
        
        instantiateSut(result: .success(data))
        
        var loginToken: LoginQRCode?
        var capturedError: Error?
        
        // WHEN
        do {
            loginToken = try await sut.generateLoginQRCodeToken()
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? ClientError)
        XCTAssertNil(loginToken)
        XCTAssertEqual(error, ClientError.malformedResponseData)
    }
    
    func test_generateLoginQRCodeToken_fails_when_httpclient_fails() async throws {
        // GIVEN
        instantiateSut(result: .failure(ClientError.malformedResponseData))
        
        var loginToken: LoginQRCode?
        var capturedError: Error?
        
        // WHEN
        do {
            loginToken = try await sut.generateLoginQRCodeToken()
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? ClientError)
        XCTAssertNil(loginToken)
        XCTAssertEqual(error, ClientError.malformedResponseData)
    }
    
    func test_validateLoginQRCodeToken_succeeds_when_httpclient_returns_a_valid_json() async {
        // GIVEN
        let data =
        """
            {
                "api_token":"29fa8b5ff37b7928357",
                "expires_at":"2024-05-28T00:00:00Z",
                "kape_user_id":"781187"
        }
        """.data(using: .utf8)!
        
        instantiateSut(result: .success(data), apiToken: "apiToken")
        var capturedApiToken: String?
        let loginQRCode = LoginQRCode(token: "dasdqe", expiresAt: Date.makeISO8601Date(string: "2024-05-28T00:00:00Z")!)
        
        // WHEN
        do {
            capturedApiToken = try await sut.validateLoginQRCodeToken(loginQRCode)
        } catch {
            XCTFail("Expected success, got error \(error)")
        }
        
        // THEN
        XCTAssertEqual(capturedApiToken, "apiToken")
    }
    
    func test_validateLoginQRCodeToken_succeeds_when_httpclient_returns_an_invalid_json() async throws {
        // GIVEN
        let data =
        """
            {
                "apitoken":"29fa8b5ff37b7928357",
                "expiresat":"2024-05-28T00:00:00Z",
                "kape_user_id":"781187"
        }
        """.data(using: .utf8)!
        
        instantiateSut(result: .success(data))
        
        let loginQRCode = LoginQRCode(token: "dasdqe", expiresAt: Date.makeISO8601Date(string: "2023-05-28T00:00:00Z")!)
        var capturedApiToken: String?
        var capturedError: Error?
        
        // WHEN
        do {
            capturedApiToken = try await sut.validateLoginQRCodeToken(loginQRCode)
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? LoginQRCodeError)
        XCTAssertNil(capturedApiToken)
        XCTAssertEqual(error, LoginQRCodeError.expired)
    }
    
    func test_validateLoginQRCodeToken_fails_when_httpclient_fails() async throws {
        // GIVEN
        instantiateSut(result: .failure(ClientError.malformedResponseData))
        
        let loginQRCode = LoginQRCode(token: "dasdqe", expiresAt: Date.makeISO8601Date(string: "2023-05-28T00:00:00Z")!)
        var capturedApiToken: String?
        var capturedError: Error?
        
        // WHEN
        do {
            capturedApiToken = try await sut.validateLoginQRCodeToken(loginQRCode)
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? LoginQRCodeError)
        XCTAssertNil(capturedApiToken)
        XCTAssertEqual(error, LoginQRCodeError.expired)
    }
}
