//
//  RegionsListUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: RegionsListUseCase.self)

protocol RegionsListUseCaseType {
    func getCurrentServers() -> [ServerType]
    func select(server: ServerType)
}

class RegionsListUseCase: RegionsListUseCaseType {

    private let serverProvider: ServerProviderType
    private var clientPreferences: ClientPreferencesType
    private let vpnConnectionUseCase: VpnConnectionUseCaseType
    
    init(serverProvider: ServerProviderType, clientPreferences: ClientPreferencesType, vpnConnectionUseCase: VpnConnectionUseCaseType) {
        self.serverProvider = serverProvider
        self.clientPreferences = clientPreferences
        self.vpnConnectionUseCase = vpnConnectionUseCase
    }
    
    func getCurrentServers() -> [ServerType] {
        return serverProvider.currentServersType
    }
    
    func select(server: ServerType) {
        log.info("Server selected: \(server.identifier)")
        clientPreferences.selectedServer = server
        Task {
            do {
                try await vpnConnectionUseCase.connect()
            } catch {
                // TODO: Handle error
                log.error("Connection error after selecting server: \(error)")
            }
        }
    }
}
