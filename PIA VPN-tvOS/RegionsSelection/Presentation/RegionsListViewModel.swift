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
    @Published var servers: [ServerType] = []
    
    init(useCase: RegionsListUseCaseType) {
        self.useCase = useCase
        refreshRegionsList()
    }
    
    func refreshRegionsList() {
        servers = useCase.getCurrentServers()
    }
    
    
    func didSelectRegionServer(_ server: ServerType) {
        useCase.select(server: server)
        // TODO: Navigate back to the Dashboard
    }
}
