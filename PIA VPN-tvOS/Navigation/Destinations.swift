//
//  Destinations.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/10/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

typealias Destinations = Hashable

enum DashboardDestinations: Destinations, Codable {
    case home
}

enum RegionsDestinations: Destinations, Codable {
    case serversList
    case search
    
    static func == (lhs: RegionsDestinations, rhs: RegionsDestinations) -> Bool {
        switch (lhs, rhs) {
        case(.serversList, .serversList):
            return true
        case(.search, .search):
            return true
        default:
            return false
            
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .serversList:
            return hasher.combine("serversList")
        case .search:
            return hasher.combine("searchRegions")
        }
    }
}
