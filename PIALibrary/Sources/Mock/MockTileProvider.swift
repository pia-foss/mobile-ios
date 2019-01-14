//
//  MockTileProvider.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation

public class MockTileProvider: TileProvider {
    
    public var visibleTiles: [AvailableTiles] = AvailableTiles.allTiles()
    
    public var orderedTiles: [AvailableTiles] = AvailableTiles.defaultOrderedTiles()

    /// :nodoc:
    public init() {
    }

}
