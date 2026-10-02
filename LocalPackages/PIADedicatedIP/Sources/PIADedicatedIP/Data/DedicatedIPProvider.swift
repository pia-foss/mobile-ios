//
//  DedicatedIPProvider.swift
//  PIADedicatedIP
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

public final class DedicatedIPProvider: DedicatedIPProviderType {
    private let serverProvider: DipServerProviderType
    private let makeServerType: @Sendable (Server) -> ServerType

    public init(
        serverProvider: DipServerProviderType,
        makeServerType: @escaping @Sendable (Server) -> ServerType
    ) {
        self.serverProvider = serverProvider
        self.makeServerType = makeServerType
    }

    public func activateDIPToken(_ token: String, completion: @escaping (Result<ServerType, DedicatedIPError>) -> Void) {
        guard getDIPTokens().isEmpty else {
            completion(.failure(.alreadyHasOne))
            return
        }
        serverProvider.activateDIPToken(token) { [makeServerType] result in
            switch result {
            case .failure(let error):
                completion(.failure(.generic(error)))

            case .success(let server) where server.dipStatus != .active:
                let status = server.dipStatus ?? .error
                completion(.failure(status.toDedicatedIPError()))

            case .success(let server):
                completion(.success(makeServerType(server)))
            }
        }
    }

    public func removeDIPToken(_ token: String) {
        serverProvider.removeDIPToken(token)
    }

    public func renewDIPToken(_ token: String) {
        serverProvider.handleDIPTokenExpiration(dipToken: token, nil)
    }

    public func getDIPTokens() -> [String] {
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
