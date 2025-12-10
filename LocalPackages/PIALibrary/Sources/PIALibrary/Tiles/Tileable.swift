//
//  Tileable.swift
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
import UIKit

typealias Func = () -> Void

public protocol Tileable {
    
    var view: UIView! {get set}
    var detailSegueIdentifier: String! {get set}
    var status: TileStatus {get set}
    
    func isEditable() -> Bool
    func isExpandable() -> Bool
    func hasDetailView() -> Bool
    
}

public extension Tileable {

    ///Check if the tile can change the visibility or the order in the list
    /// - Returns: Bool
    func isEditable() -> Bool {
        return false
    }
    
    ///Check if the tile can change the size inside the list
    /// - Returns: Bool
    func isExpandable() -> Bool {
        return false
    }
    
    ///Check if the tile has a detail view controller
    /// - Returns: Bool
    func hasDetailView() -> Bool {
        return false
    }
    
}
