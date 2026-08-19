//
//  ValidateLoginQRCodeUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 5/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol ValidateLoginQRCodeUseCaseType {
    func callAsFunction(qrCodeToken: LoginQRCode) async throws
}

class ValidateLoginQRCodeUseCase: ValidateLoginQRCodeUseCaseType {
    private let accountProviderType: AccountProvider
    private let validateLoginQRCodeProvider: ValidateLoginQRCodeProviderType

    init(accountProviderType: AccountProvider, validateLoginQRCodeProvider: ValidateLoginQRCodeProviderType) {
        self.accountProviderType = accountProviderType
        self.validateLoginQRCodeProvider = validateLoginQRCodeProvider
    }

    func callAsFunction(qrCodeToken: LoginQRCode) async throws {
        let apiToken = try await validateLoginQRCodeProvider.validateLoginQRCodeToken(qrCodeToken)

        return try await withCheckedThrowingContinuation { continuation in
            accountProviderType.login(with: apiToken) { result in
                if case let .failure(error) = result {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }
}
