//
//  RefreshLatencyFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 3/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class RefreshLatencyFactory {
    static var makeClientAdapter: ClientType = {
        ClientAdapter()
    }()
    
    static var makeRefreshServersLatencyUseCase: RefreshServersLatencyUseCaseType = {
        RefreshServersLatencyUseCase(client: makeClientAdapter, serverProvider: VpnConnectionFactory.makeServerProvider(), notificationCenter: NotificationCenter.default, connectionStateMonitor: StateMonitorsFactory.makeConnectionStateMonitor
        )
    }()
}
