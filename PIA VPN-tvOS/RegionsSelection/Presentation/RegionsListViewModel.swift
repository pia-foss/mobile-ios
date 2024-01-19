//
//  RegionsListViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class RegionsListViewModel: ObservableObject {
    
    private let useCase: RegionsListUseCaseType
    private let onServerSelectedRouterAction: AppRouter.Actions
    @Published var servers: [ServerType] = []
    
    init(useCase: RegionsListUseCaseType, onServerSelectedRouterAction: AppRouter.Actions) {
        self.useCase = useCase
        self.onServerSelectedRouterAction = onServerSelectedRouterAction
        refreshRegionsList()
    }
    
    func refreshRegionsList() {
        servers = useCase.getCurrentServers()
    }
    
    
    func didSelectRegionServer(_ server: ServerType) {
        useCase.select(server: server)
        onServerSelectedRouterAction.execute()
    }
}
