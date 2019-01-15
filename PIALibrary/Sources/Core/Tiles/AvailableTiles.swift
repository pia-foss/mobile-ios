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

    public static func allTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip, .subscription, .usage]
    }
    
    public static func defaultTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip]
    }

    public static func defaultOrderedTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip, .subscription, .usage]
    }

}

public enum TileStatus {
    case normal
    case edit
}
