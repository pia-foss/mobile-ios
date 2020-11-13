//
//  DefaultTileProvider.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

class DefaultTileProvider: TileProvider, DatabaseAccess {
    
    // MARK: TileProvider
    var visibleTiles: [AvailableTiles] {
        get {
            var orderedVisibleTiles: [AvailableTiles] = []
            let visibleTiles = accessedDatabase.plain.visibleTiles
            let orderedTiles = accessedDatabase.plain.orderedTiles
            for item in orderedTiles where visibleTiles.contains(item) {
                orderedVisibleTiles.append(item)
            }
            return orderedVisibleTiles
        }
        set {
            accessedDatabase.plain.visibleTiles = newValue
        }
    }
    
    // MARK: TileProvider
    var fixedTiles: [AvailableTiles] {
        get {
            return AvailableTiles.fixedTiles()
        }
    }
    
    // MARK: TileProvider
    var orderedTiles: [AvailableTiles] {
        get {
            return accessedDatabase.plain.orderedTiles
        }
        set {
            accessedDatabase.plain.orderedTiles = newValue
        }
    }

}
