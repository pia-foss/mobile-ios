//
//  AvailableTiles.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation

public enum AvailableTiles: Int, EnumsBuilder {
    case region
    case quickConnect
    case ip
    case subscription
    case usage
    case networkManagementTool
    case quickSettings

    public static func allTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip, .subscription, .usage, .networkManagementTool, .quickSettings]
    }
    
    public static func defaultTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip, .quickSettings]
    }

    public static func defaultOrderedTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip, .quickSettings, .subscription, .usage, .networkManagementTool]
    }

}

public enum TileStatus {
    case normal
    case edit
}
