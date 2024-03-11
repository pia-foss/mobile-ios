//
//  ValidateLoginQRCodeUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 5/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol ValidateLoginQRCodeUseCaseType {
    func callAsFunction(expirationDate: Date) async throws
}

class ValidateLoginQRCodeUseCase: ValidateLoginQRCodeUseCaseType {
    func callAsFunction(expirationDate: Date) async throws {
        let nanoseconds = UInt64(expirationDate.timeIntervalSinceNow * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
