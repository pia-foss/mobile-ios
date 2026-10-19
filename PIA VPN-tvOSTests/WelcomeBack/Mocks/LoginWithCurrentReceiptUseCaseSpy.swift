//
//  LoginWithCurrentReceiptUseCaseSpy.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

@testable import PIA_VPN_tvOS

/// Holds the receipt sign-in open until the test completes it, so taps made while restoring can be
/// observed.
final class LoginWithCurrentReceiptUseCaseSpy: LoginWithCurrentReceiptUseCaseType {
    private(set) var callCount = 0
    private var pendingContinuation: CheckedContinuation<UserAccount, Error>?
    var onCall: (() -> Void)?

    func callAsFunction() async throws -> UserAccount {
        try await withCheckedThrowingContinuation { continuation in
            callCount += 1
            pendingContinuation = continuation
            onCall?()
        }
    }

    func complete(with result: Result<UserAccount, Error>) {
        pendingContinuation?.resume(with: result)
        pendingContinuation = nil
    }
}
