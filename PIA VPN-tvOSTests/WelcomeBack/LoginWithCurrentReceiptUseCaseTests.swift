//
//  LoginWithCurrentReceiptUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIABase
import PIALibrary
import XCTest

@testable import PIA_VPN_tvOS

final class LoginWithCurrentReceiptUseCaseTests: XCTestCase {
    private func makeSut(currentReceipt: JWS?, loginProviderResult: ClientResult<UserAccount>) -> LoginWithCurrentReceiptUseCase {
        LoginWithCurrentReceiptUseCase(
            paymentProvider: PaymentProviderMock(result: .failure(ClientError.unexpectedReply), currentReceipt: currentReceipt),
            loginProvider: LoginProviderMock(result: loginProviderResult),
            errorMapper: LoginDomainErrorMapper())
    }

    func test_login_succeeds_when_a_receipt_is_held_and_loginProvider_succeeds() async throws {
        // GIVEN
        let user = UserAccount.makeStub()
        let sut = makeSut(currentReceipt: JWS("jws-transaction")!, loginProviderResult: .success(user))

        // WHEN
        let userAccount = try await sut()

        // THEN
        XCTAssertEqual(userAccount, user)
    }

    func test_login_fails_when_no_receipt_is_held() async throws {
        // GIVEN
        let sut = makeSut(currentReceipt: nil, loginProviderResult: .success(UserAccount.makeStub()))

        // WHEN
        var capturedError: Error?
        do {
            _ = try await sut()
            XCTFail("Expected error, got success")
        } catch {
            capturedError = error
        }

        // THEN
        let error = try XCTUnwrap(capturedError as? LoginError)
        XCTAssertEqual(error, .generic(message: nil))
    }

    func test_login_fails_with_mapped_error_when_loginProvider_fails() async throws {
        // GIVEN
        let sut = makeSut(currentReceipt: JWS("jws-transaction")!, loginProviderResult: .failure(ClientError.expired))

        // WHEN
        var capturedError: Error?
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
