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
    
    /// Returns `true` if currently logged in, `false` otherwise.
    var visibleTiles: [AvailableTiles] { get set }
    
}
