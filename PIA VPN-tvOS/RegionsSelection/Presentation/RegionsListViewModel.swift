//
//  RegionsListViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import Combine

class RegionsListViewModel: ObservableObject {
    
    private let useCase: RegionsListUseCaseType
    private let onServerSelectedRouterAction: AppRouter.Actions
    @Published var servers: [ServerType] = []
    @Published var search = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: RegionsListUseCaseType, onServerSelectedRouterAction: AppRouter.Actions) {
        self.useCase = useCase
        self.onServerSelectedRouterAction = onServerSelectedRouterAction
        refreshRegionsList()
        subscribeToSearchUpdates()
    }
    
    func subscribeToSearchUpdates() {
        $search.sink { [weak self] searchTerm in
            guard let self = self else { return }
            guard !searchTerm.isEmpty else {
                self.refreshRegionsList()
                return
            }
            self.servers = self.useCase.getCurrentServers().filter({ server in
                return server.name.lowercased().contains(searchTerm.lowercased())
            })
        }.store(in: &cancellables)
    }
    
    func refreshRegionsList() {
        servers = useCase.getCurrentServers()
    }
    
    
    func didSelectRegionServer(_ server: ServerType) {
        useCase.select(server: server)
        onServerSelectedRouterAction.execute()
    }
}
