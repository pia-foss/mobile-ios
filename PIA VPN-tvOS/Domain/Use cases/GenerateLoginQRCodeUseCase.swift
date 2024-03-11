//
//  GenerateLoginQRCodeUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol GenerateLoginQRCodeUseCaseType {
    func callAsFunction() async throws -> LoginQRCode
}

class GenerateLoginQRCodeUseCase: GenerateLoginQRCodeUseCaseType {
    func callAsFunction() async throws -> LoginQRCode {
        let nanoseconds = UInt64(2 * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
        
        return LoginQRCode(url: URL(string: "https://www.google.com")!,
                           expiresAt: Date.now.addingTimeInterval(10))
    }
}
