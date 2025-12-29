//
//  AvailableTiles.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 25/11/2019.
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

import UIKit
import PIALibrary
import PIAUIKit

class FeedbackTileCollectionViewCell: UICollectionViewCell, TileableCell {
    
    var tileType: AvailableTiles = .feedback

    typealias Entity = FeedbackTile
    @IBOutlet private weak var tile: Entity!
    @IBOutlet weak var accessoryImageRight: UIImageView!
    @IBOutlet weak var accessoryButtonLeft: UIButton!
    @IBOutlet weak var tileLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tileRightConstraint: NSLayoutConstraint!
    
    private var currentTileStatus: TileStatus?

    func setupCellForStatus(_ status: TileStatus) {
        self.accessibilityIdentifier = "FeedbackTileCollectionViewCell"
        
        Theme.current.applyPrincipalBackground(self)
        Theme.current.applyPrincipalBackground(self.contentView)
        self.accessoryImageRight.image = Theme.current.dragDropImage()
        tile.status = status
        let animationDuration = currentTileStatus != nil ? AppConfiguration.Animations.duration : 0
        UIView.animate(withDuration: animationDuration, animations: {
            self.tileLeftConstraint.constant = 0
            self.tileRightConstraint.constant = 0
            self.accessoryButtonLeft.isHidden = true
            self.accessoryImageRight.isHidden = true
            self.layoutIfNeeded()
            self.currentTileStatus = status
        })
    }
}
