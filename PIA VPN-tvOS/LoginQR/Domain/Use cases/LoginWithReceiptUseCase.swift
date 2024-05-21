//
//  LoginWithReceiptUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 20/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol LoginWithReceiptUseCaseType {
    func callAsFunction() async throws -> UserAccount
}

class LoginWithReceiptUseCase: LoginWithReceiptUseCaseType {
    private let paymentProvider: PaymentProviderType
    private let loginProvider: LoginProviderType
    private let errorMapper: LoginDomainErrorMapperType
    
    init(paymentProvider: PaymentProviderType, loginProvider: LoginProviderType, errorMapper: LoginDomainErrorMapperType) {
        self.paymentProvider = paymentProvider
        self.loginProvider = loginProvider
        self.errorMapper = errorMapper
    }
    
    func callAsFunction() async throws -> UserAccount {
        return try await withCheckedThrowingContinuation { continuation in
            paymentProvider.refreshPaymentReceipt { [weak self] result in
                guard let self else { return }
                
                switch result {
                    case .success(let receipt):
                        login(with: receipt, continuation: continuation)
                        
                    case .failure(let error):
                        continuation.resume(throwing: errorMapper.map(error: error))
                }
            }
        }
    }
    
    private func login(with receipt: Data, continuation: CheckedContinuation<UserAccount, any Error>) {
        loginProvider.login(with: Data()) { [weak self] result in
            guard let self else { return }
            
            switch result {
                case .success(let userAccount):
                    continuation.resume(returning: userAccount)
                case .failure(let error):
                    continuation.resume(throwing: errorMapper.map(error: error))
            }
        }
    }
}
