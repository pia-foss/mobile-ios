//
//  TileProvider.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation

/// Business interface related to the tiles.
public protocol TileProvider: class {
    
    /// the visible tiles in the dashboard.
    var visibleTiles: [AvailableTiles] { get set }

    /// the order of the tiles to appear in the dashboard.
    var orderedTiles: [AvailableTiles] { get set }

}
