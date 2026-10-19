//
//  LoginWithCurrentReceiptUseCase.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIABase
import PIALibrary

private let log = PIALogger.logger(for: LoginWithCurrentReceiptUseCase.self)

protocol LoginWithCurrentReceiptUseCaseType {
    func callAsFunction() async throws -> UserAccount
}

/// Signs in with the receipt the App Store already holds. Unlike `LoginWithReceiptUseCase` it does
/// not sync with the App Store first, so it never prompts for the Apple ID password.
class LoginWithCurrentReceiptUseCase: LoginWithCurrentReceiptUseCaseType {
    private let paymentProvider: PaymentProviderType
    private let loginProvider: LoginProviderType
    private let errorMapper: LoginDomainErrorMapperType

    init(paymentProvider: PaymentProviderType, loginProvider: LoginProviderType, errorMapper: LoginDomainErrorMapperType) {
        self.paymentProvider = paymentProvider
        self.loginProvider = loginProvider
        self.errorMapper = errorMapper
    }

    func callAsFunction() async throws -> UserAccount {
        guard let receipt = await paymentProvider.currentPaymentReceipt() else {
            log.info("No subscription receipt to sign in with")
            throw LoginError.generic(message: nil)
        }

        return try await withCheckedThrowingContinuation { continuation in
            loginProvider.login(with: receipt) { [errorMapper] result in
                switch result {
                case .success(let userAccount):
                    continuation.resume(returning: userAccount)
                case .failure(let error):
                    continuation.resume(throwing: errorMapper.map(error: error))
                }
            }
        }
    }
}
