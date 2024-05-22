//
//  LoginWithReceiptUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 21/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary

final class LoginWithReceiptUseCaseTests: XCTestCase {
    class Fixture {
        var paymentProviderMock: PaymentProviderMock!
        var loginProviderMock: LoginProviderMock!
        var errorMapper = LoginDomainErrorMapper()
    }
    
    var fixture: Fixture!
    var sut: LoginWithReceiptUseCase!
    
    func instantiateSut(paymentProviderResult: Result<Data, Error>, loginProviderResult: Result<PIA_VPN_tvOS.UserAccount, Error>) {
        fixture.paymentProviderMock = PaymentProviderMock(result: paymentProviderResult)
        fixture.loginProviderMock = LoginProviderMock(result: loginProviderResult)
        
        sut = LoginWithReceiptUseCase(paymentProvider: fixture.paymentProviderMock,
                                      loginProvider: fixture.loginProviderMock,
                                      errorMapper: fixture.errorMapper)
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    func test_login_succeeds_when_paymentProvider_completes_with_receipt_and_loginprovider_completes_with_success() async throws {
        // GIVEN
        let receipt = Data()
        let user = PIA_VPN_tvOS.UserAccount.makeStub()
        
        instantiateSut(paymentProviderResult: .success(receipt),
                       loginProviderResult: .success(user))
        
        // WHEN
        let userAccount = try await sut()
        
        // THEN
        XCTAssertEqual(userAccount, user)
    }
    
    func test_login_fails_when_paymentProvider_completes_with_failure() async throws {
        // GIVEN
        let user = PIA_VPN_tvOS.UserAccount.makeStub()
        
        instantiateSut(paymentProviderResult: .failure(ClientError.expired),
                       loginProviderResult: .success(user))
        
        var capturedError: Error?
        
        // WHEN
        do {
            _ = try await sut()
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? LoginError)
        XCTAssertEqual(error, .expired)
    }
    
    func test_login_fails_when_paymentProvider_completes_with_receipt_and_loginprovider_completes_with_failure() async throws {
        // GIVEN
        let receipt = Data()
        instantiateSut(paymentProviderResult: .success(receipt),
                       loginProviderResult: .failure(ClientError.expired))
        
        var capturedError: Error?
        
        // WHEN
        do {
            _ = try await sut()
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }
        
        // THEN
        let error = try XCTUnwrap(capturedError as? LoginError)
        XCTAssertEqual(error, .expired)
    }

}
