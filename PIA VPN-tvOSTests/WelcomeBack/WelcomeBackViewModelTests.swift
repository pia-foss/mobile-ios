//
//  WelcomeBackViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIALibrary
import XCTest

@testable import PIA_VPN_tvOS

@MainActor
final class WelcomeBackViewModelTests: XCTestCase {

    private var loginSpy: LoginWithCurrentReceiptUseCaseSpy!
    private var successCount = 0
    private var requestLoginCount = 0
    private var dismissCount = 0
    private var onSuccess: (() -> Void)?
    private var onDismiss: (() -> Void)?

    override func setUp() {
        loginSpy = LoginWithCurrentReceiptUseCaseSpy()
        successCount = 0
        requestLoginCount = 0
        dismissCount = 0
        onSuccess = nil
        onDismiss = nil
    }

    override func tearDown() {
        loginSpy = nil
        onSuccess = nil
        onDismiss = nil
    }

    private func makeSut() -> WelcomeBackViewModel {
        WelcomeBackViewModel(
            loginWithCurrentReceipt: loginSpy,
            onSuccessAction: { [unowned self] in
                successCount += 1
                onSuccess?()
            },
            onRequestLoginAction: { [unowned self] in requestLoginCount += 1 },
            onDismissAction: { [unowned self] in
                dismissCount += 1
                onDismiss?()
            })
    }

    /// Taps the App Store button and waits until the receipt sign-in has started.
    private func tapAppStoreAccountAndWaitForLogin(on sut: WelcomeBackViewModel) {
        let loginStarted = expectation(description: "Receipt sign-in started")
        loginSpy.onCall = { loginStarted.fulfill() }
        sut.appStoreAccountTapped()
        wait(for: [loginStarted], timeout: 1.0)
        loginSpy.onCall = nil
    }

    func test_appStoreAccount_signsInOnce_andSucceeds() {
        let sut = makeSut()

        tapAppStoreAccountAndWaitForLogin(on: sut)
        XCTAssertTrue(sut.isRestoring)

        let succeeded = expectation(description: "Success action")
        onSuccess = { succeeded.fulfill() }
        loginSpy.complete(with: .success(UserAccount.makeStub()))
        wait(for: [succeeded], timeout: 1.0)

        XCTAssertEqual(loginSpy.callCount, 1)
        XCTAssertEqual(successCount, 1)
        XCTAssertEqual(dismissCount, 0)
        XCTAssertFalse(sut.isRestoring)
    }

    func test_appStoreAccount_isIgnoredWhileRestoring() {
        let sut = makeSut()
        tapAppStoreAccountAndWaitForLogin(on: sut)

        sut.appStoreAccountTapped()

        let succeeded = expectation(description: "Success action")
        onSuccess = { succeeded.fulfill() }
        loginSpy.complete(with: .success(UserAccount.makeStub()))
        wait(for: [succeeded], timeout: 1.0)

        XCTAssertEqual(loginSpy.callCount, 1)
        XCTAssertEqual(successCount, 1)
    }

    func test_appStoreAccount_whenSignInFails_dismisses() {
        let sut = makeSut()
        tapAppStoreAccountAndWaitForLogin(on: sut)

        let dismissed = expectation(description: "Dismiss action")
        onDismiss = { dismissed.fulfill() }
        loginSpy.complete(with: .failure(LoginError.unauthorized))
        wait(for: [dismissed], timeout: 1.0)

        XCTAssertEqual(successCount, 0)
        XCTAssertEqual(dismissCount, 1)
        XCTAssertFalse(sut.isRestoring)
    }

    func test_appStoreAccount_whenAccountIsExpired_dismisses() {
        let sut = makeSut()
        tapAppStoreAccountAndWaitForLogin(on: sut)

        let dismissed = expectation(description: "Dismiss action")
        onDismiss = { dismissed.fulfill() }
        loginSpy.complete(with: .failure(LoginError.expired))
        wait(for: [dismissed], timeout: 1.0)

        XCTAssertEqual(successCount, 0)
        XCTAssertEqual(dismissCount, 1)
    }

    func test_usernameAndPassword_requestsLoginWithoutSigningIn() {
        let sut = makeSut()

        sut.usernameAndPasswordTapped()

        XCTAssertEqual(requestLoginCount, 1)
        XCTAssertEqual(loginSpy.callCount, 0)
        XCTAssertEqual(dismissCount, 0)
    }

    func test_usernameAndPassword_isIgnoredWhileRestoring() {
        let sut = makeSut()
        tapAppStoreAccountAndWaitForLogin(on: sut)

        sut.usernameAndPasswordTapped()

        XCTAssertEqual(requestLoginCount, 0)
    }
}
