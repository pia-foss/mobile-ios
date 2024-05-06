//
//  SignupUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol SignupUseCaseType {
    func callAsFunction(email: String, transaction: InAppTransaction?) async throws -> UserAccount
}

class SignupUseCase: SignupUseCaseType {
    private let signupProvider: SignupProviderType
    
    init(signupProvider: SignupProviderType) {
        self.signupProvider = signupProvider
    }
    
    func callAsFunction(email: String, transaction: InAppTransaction?) async throws -> UserAccount {
        return try await withCheckedThrowingContinuation { continuation in
            signupProvider.signup(email: email, transaction: transaction) { result in
                switch result {
                case .success(let userAccount):
                    continuation.resume(returning: userAccount)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
