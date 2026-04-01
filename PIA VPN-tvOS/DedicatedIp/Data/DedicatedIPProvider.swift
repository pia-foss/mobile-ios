//
//  DedicatedIPProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class DedicatedIPProvider: DedicatedIPProviderType {
    private let serverProvider: DipServerProviderType
    
    init(serverProvider: DipServerProviderType) {
        self.serverProvider = serverProvider
    }
    
    func activateDIPToken(_ token: String, completion: @escaping (Result<Void, DedicatedIPError>) -> Void) {
        serverProvider.activateDIPToken(token) { server, error in
            if let error = error {
                completion(.failure(DedicatedIPError.generic(error)))
                return
            }
            
            guard let server = server, let status = server?.dipStatus else {
                completion(.failure(DedicatedIPError.generic(nil)))
                return
            }
            
            guard status == .active else {
                completion(.failure(status.toDedicatedIPError()))
                return
            }
            
            completion(.success(()))
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
