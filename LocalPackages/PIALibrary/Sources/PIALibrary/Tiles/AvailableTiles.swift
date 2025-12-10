//
//  AvailableTiles.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

public enum AvailableTiles: Int, EnumsBuilder {
    case region
    case quickConnect
    case ip
    case subscription
    case usage
    case quickSettings
    case favoriteServers
    case connectionTile
    case feedback
    case messages

    public static func fixedTiles() -> [AvailableTiles] {
        return [.messages, .feedback]
    }

    public static func allTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip, .subscription, .usage, .quickSettings, .favoriteServers, .connectionTile]
    }
    
    public static func defaultTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .ip, .quickSettings]
    }

    public static func defaultOrderedTiles() -> [AvailableTiles] {
        return [.region, .quickConnect, .favoriteServers, .ip, .connectionTile, .quickSettings, .subscription, .usage]
    }

}

public enum TileStatus {
    case normal
    case edit
}
