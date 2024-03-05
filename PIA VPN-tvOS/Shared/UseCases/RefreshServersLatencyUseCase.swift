//
//  RefreshServersLatencyUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 3/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine

protocol RefreshServersLatencyUseCaseType {
    var statePublisher: Published<RefreshServersLatencyUseCase.State>.Publisher { get }
    func callAsFunction()
}

class RefreshServersLatencyUseCase: RefreshServersLatencyUseCaseType {
    
    private let client: ClientType
    private let serverProvider: ServerProviderType
    private let notificationCenter: NotificationCenterType
    
    enum State: Equatable {
        case none
        case updating
        case updated
    }
    
    @Published private(set) var state: State = .none
    var statePublisher: Published<State>.Publisher {
        $state
    }
    
    init(client: ClientType, serverProvider: ServerProviderType, notificationCenter: NotificationCenterType) {
        self.client = client
        self.serverProvider = serverProvider
        self.notificationCenter = notificationCenter
        
        subscribeToServersPingingUpdates()
    }
    
    func callAsFunction() {
        guard state != .updating else { return }
        state = .updating
        let servers = serverProvider.currentServersType
        client.ping(servers: servers)
    }
}

// MARK: - NotificationCenter subscription

extension RefreshServersLatencyUseCase {
    
    private func subscribeToServersPingingUpdates() {
        notificationCenter.publisher(for: .PIADaemonsDidPingServers, object: nil)
            .map { _ in
                return State.updated
            }.assign(to: &$state)
    }
    
}
