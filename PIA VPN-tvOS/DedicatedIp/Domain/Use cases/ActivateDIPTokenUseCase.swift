//
//  ActivateDIPTokenUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol ActivateDIPTokenUseCaseType {
    func callAsFunction(token: String) async throws
}

class ActivateDIPTokenUseCase: ActivateDIPTokenUseCaseType {
    private let dipServerProvider: DedicatedIPProviderType
    
    init(dipServerProvider: DedicatedIPProviderType) {
        self.dipServerProvider = dipServerProvider
    }
    
    func callAsFunction(token: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            dipServerProvider.activateDIPToken(token) { result in
                switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        }
    }
}
