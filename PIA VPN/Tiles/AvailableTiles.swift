//
//  AvailableTiles.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation

enum TileSections: Int, EnumsBuilder {
    case power
    case tiles
}

enum AvailablePowerTiles: Int, EnumsBuilder {
    case power
}

enum AvailableTiles: Int, EnumsBuilder {
    case regions
    case ip
}
