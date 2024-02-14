//
//  GetDedicatedIpUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol GetDedicatedIpUseCaseType {
    func callAsFunction() -> ServerType?
}

class GetDedicatedIpUseCase: GetDedicatedIpUseCaseType {
    private let serverProvider: ServerProviderType
    private let dedicatedIpProvider: DedicatedIPProviderType
    
    init(serverProvider: ServerProviderType, dedicatedIpProvider: DedicatedIPProviderType) {
        self.serverProvider = serverProvider
        self.dedicatedIpProvider = dedicatedIpProvider
    }
    
    func callAsFunction() -> ServerType? {
        let dipTokens = dedicatedIpProvider.getDIPTokens()
        return serverProvider.currentServersType
            .filter({ $0.dipToken != nil && dipTokens.contains($0.dipToken!) })
            .first
    }
}
