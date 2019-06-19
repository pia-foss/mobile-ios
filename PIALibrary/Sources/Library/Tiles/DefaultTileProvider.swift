//
//  DefaultTileProvider.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
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
    var orderedTiles: [AvailableTiles] {
        get {
            return accessedDatabase.plain.orderedTiles
        }
        set {
            accessedDatabase.plain.orderedTiles = newValue
        }
    }

}
