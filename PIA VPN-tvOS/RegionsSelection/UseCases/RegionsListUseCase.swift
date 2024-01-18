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
    func select(server: ServerType)
}

class RegionsListUseCase: RegionsListUseCaseType {

    private let serverProvider: ServerProviderType
    private var clientPreferences: ClientPreferencesType
    
    init(serverProvider: ServerProviderType, clientPreferences: ClientPreferencesType) {
        self.serverProvider = serverProvider
        self.clientPreferences = clientPreferences
    }
    
    func getCurrentServers() -> [ServerType] {
        return serverProvider.currentServers
    }
    
    func select(server: ServerType) {
        // This triggers a connection
        clientPreferences.selectedServer = server
    }
    
    
}
