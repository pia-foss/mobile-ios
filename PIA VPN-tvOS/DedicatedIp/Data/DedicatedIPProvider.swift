//
//  DedicatedIPProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

final class DedicatedIPProvider: DedicatedIPProviderType {
    private let serverProvider: DipServerProviderType

    init(serverProvider: DipServerProviderType) {
        self.serverProvider = serverProvider
    }

    func activateDIPToken(_ token: String, completion: @escaping (Result<ServerType, DedicatedIPError>) -> Void) {
        guard getDIPTokens().isEmpty else {
            completion(.failure(.alreadyHasOne))
            return
        }
        serverProvider.activateDIPToken(token) { result in
            switch result {
            case .failure(let error):
                completion(.failure(.generic(error)))

            case .success(let server) where server.dipStatus != .active:
                let status = server.dipStatus ?? .error
                completion(.failure(status.toDedicatedIPError()))

            case .success(let server):
                completion(.success(server))
            }
        }
    }

    func removeDIPToken(_ token: String) {
        serverProvider.removeDIPToken(token)
    }

    func renewDIPToken(_ token: String) {
        serverProvider.handleDIPTokenExpiration(dipToken: token, nil)
    }

    func getDIPTokens() -> [String] {
        serverProvider.getDIPTokens()
    }
}

private extension DedicatedIPStatus {
    func toDedicatedIPError() -> DedicatedIPError {
        switch self {
        case .expired:
            return DedicatedIPError.expired
        case .invalid:
            return DedicatedIPError.invalid
        default:
            return DedicatedIPError.generic(nil)
        }
    }
}
