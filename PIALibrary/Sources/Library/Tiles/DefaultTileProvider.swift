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
            return accessedDatabase.plain.visibleTiles
        }
        set {
            accessedDatabase.plain.visibleTiles = newValue
        }
    }

}
