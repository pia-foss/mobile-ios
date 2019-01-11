//
//  Tileable.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
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
