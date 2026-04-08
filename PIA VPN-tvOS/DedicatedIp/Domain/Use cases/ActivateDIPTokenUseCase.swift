//
//  ActivateDIPTokenUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: ActivateDIPTokenUseCase.self)

protocol ActivateDIPTokenUseCaseType {
    func callAsFunction(token: String) async throws
}

class ActivateDIPTokenUseCase: ActivateDIPTokenUseCaseType {
    private let dipServerProvider: DedicatedIPProviderType
    
    init(dipServerProvider: DedicatedIPProviderType) {
        self.dipServerProvider = dipServerProvider
    }
    
    func callAsFunction(token: String) async throws {
        log.info("Activating DIP token")
        return try await withCheckedThrowingContinuation { continuation in
            dipServerProvider.activateDIPToken(token) { result in
                switch result {
                    case .success:
                        log.info("DIP token activated successfully")
                        continuation.resume()
                    case .failure(let error):
                        log.error("DIP token activation failed: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                }
            }
        }
    }
}
