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
    func callAsFunction(token: String) async -> Result<Void, DedicatedIPError>
}

final class ActivateDIPTokenUseCase: ActivateDIPTokenUseCaseType {
    private let dipServerProvider: DedicatedIPProviderType

    init(dipServerProvider: DedicatedIPProviderType) {
        self.dipServerProvider = dipServerProvider
    }

    func callAsFunction(token: String) async -> Result<Void, DedicatedIPError> {
        log.info("Activating DIP token")
        return await withCheckedContinuation { continuation in
            dipServerProvider.activateDIPToken(token) { result in
                switch result {
                case .success:
                    log.info("DIP token activated successfully")
                case .failure(let error):
                    log.error("DIP token activation failed: \(error)")
                }
                continuation.resume(returning: result)
            }
        }
    }
}
