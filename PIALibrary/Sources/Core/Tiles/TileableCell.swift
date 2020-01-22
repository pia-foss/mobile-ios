//
//  TileableCell.swift
//  PIA VPN
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
import UIKit

public protocol EditableTileCell {
    
    func setupCellForStatus(_ status: TileStatus)
    
}

public protocol DetailedTileCell: EditableTileCell {
    
    func hasDetailView() -> Bool
    func segueIdentifier() -> String?
    func highlightCell()
    func unhighlightCell()

}

public protocol TileableCell: DetailedTileCell {
    
    associatedtype Entity
    var tileType: AvailableTiles { get }
    
    var accessoryImageRight: UIImageView! { get set }
    var accessoryButtonLeft: UIButton!  { get set }
    var tileLeftConstraint: NSLayoutConstraint!  { get set }
    var tileRightConstraint: NSLayoutConstraint! { get set }

}

public extension TileableCell where Entity: Tileable {
    
    var leftConstraintValue: CGFloat {
        return 34
    }

    var rightConstraintValue: CGFloat {
        return 40
    }
    
    func hasDetailView() -> Bool {
        return false
    }
    
    func segueIdentifier() -> String? {
        return nil
    }

    func highlightCell() {
    }
    
    func unhighlightCell() {
    }
    
}
