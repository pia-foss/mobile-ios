//
//  ValidateLoginQRCodeUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 5/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol ValidateLoginQRCodeUseCaseType {
    func callAsFunction(qrCodeToken: LoginQRCode) async throws
}

class ValidateLoginQRCodeUseCase: ValidateLoginQRCodeUseCaseType {
    private let accountProviderType: AccountProviderType
    private let validateLoginQRCodeProvider: ValidateLoginQRCodeProviderType
    
    init(accountProviderType: AccountProviderType, validateLoginQRCodeProvider: ValidateLoginQRCodeProviderType) {
        self.accountProviderType = accountProviderType
        self.validateLoginQRCodeProvider = validateLoginQRCodeProvider
    }
    
    func callAsFunction(qrCodeToken: LoginQRCode) async throws {
        let apiToken = try await validateLoginQRCodeProvider.validateLoginQRCodeToken(qrCodeToken)
        
        return try await withCheckedThrowingContinuation { continuation in
            accountProviderType.login(with: apiToken) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }
}
