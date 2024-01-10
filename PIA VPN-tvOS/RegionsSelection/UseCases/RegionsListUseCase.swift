//
//  RegionsListUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol RegionsListUseCaseType {
    func getCurrentServers() -> [ServerType]
}

class RegionsListUseCase: RegionsListUseCaseType {
    
    private let serverProvider: ServerProviderType
    
    init(serverProvider: ServerProviderType) {
        self.serverProvider = serverProvider
    }
    
    func getCurrentServers() -> [ServerType] {
        return serverProvider.currentServers
    }
}
