//
//  Destinations.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/10/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

typealias Destinations = Hashable

enum DashboardDestinations: Destinations {
    case home
}

enum RegionSelectionDestinations: Destinations {
    case search
}

enum RegionsDestinations: Destinations {
    case serversList
    case selectServer(_: ServerType)
    
    static func == (lhs: RegionsDestinations, rhs: RegionsDestinations) -> Bool {
        switch (lhs, rhs) {
        case(.serversList, .serversList):
            return true
        case(.serversList, .selectServer): return false
        case(.selectServer, .serversList): return false
        case (.selectServer(let lhsServer), .selectServer(let rhsServer)):
            return lhsServer.identifier == rhsServer.identifier
            
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .serversList:
            return hasher.combine("serversList")
        case .selectServer(let server):
            return hasher.combine("selectedServer\(server.identifier)")
        }
    }
}

