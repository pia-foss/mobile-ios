//
//  ServerSelectingTile.swift
//  PIA VPN
//
//  Created by Miguel Berrocal on 23/7/21.
//  Copyright © 2021 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol ServerSelectingCell: AnyObject {
    var delegate: ServerSelectionDelegate? {get set}
}
