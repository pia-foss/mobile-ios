//
//  RegionTileCollectionViewCell.swift
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

import UIKit
import PIALibrary

class RegionTileCollectionViewCell: UICollectionViewCell, TileableCell {
    
    var tileType: AvailableTiles = .region

    typealias Entity = RegionTile
    @IBOutlet private weak var tile: Entity!
    @IBOutlet weak var accessoryImageRight: UIImageView!
    @IBOutlet weak var accessoryButtonLeft: UIButton!
    @IBOutlet weak var tileLeftConstraint: NSLayoutConstraint!
    var tileRightConstraint: NSLayoutConstraint! 

    private var currentTileStatus: TileStatus?

    func hasDetailView() -> Bool {
        return tile.hasDetailView()
    }
    
    func segueIdentifier() -> String? {
        return tile.detailSegueIdentifier
    }
    
    func setupCellForStatus(_ status: TileStatus) {
        self.accessibilityIdentifier = "RegionTileCollectionViewCell"
        self.accessibilityLabel = L10n.Tiles.Region.title
        Theme.current.applyPrincipalBackground(self)
        Theme.current.applyPrincipalBackground(self.contentView)
        tile.status = status
        let animationDuration = currentTileStatus != nil ? AppConfiguration.Animations.duration : 0
        UIView.animate(withDuration: animationDuration, animations: {
            switch status {
            case .normal:
                self.accessibilityTraits = UIAccessibilityTraits.button
                self.isAccessibilityElement = true
                self.accessoryImageRight.image = Asset.Piax.Tiles.openTileDetails.image
                self.tileLeftConstraint.constant = 0
                self.accessoryButtonLeft.isHidden = true
            case .edit:
                self.accessibilityTraits = UIAccessibilityTraits.none
                self.isAccessibilityElement = false
                self.accessoryImageRight.image = Theme.current.dragDropImage()
                self.tileLeftConstraint.constant = self.leftConstraintValue
                self.setupVisibilityButton()
                self.accessoryButtonLeft.isHidden = false
            }
            self.layoutIfNeeded()
            self.currentTileStatus = status
        })
    }
    
    
    func highlightCell() {
        accessoryImageRight.alpha = 0
        Theme.current.applySecondaryBackground(tile)
        Theme.current.applySecondaryBackground(self)
        Theme.current.applySecondaryBackground(self.contentView)
    }
    
    func unhighlightCell() {
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: { [weak self] in
            self?.accessoryImageRight.alpha = 1
        })
        Theme.current.applyPrincipalBackground(tile)
        Theme.current.applyPrincipalBackground(self)
        Theme.current.applyPrincipalBackground(self.contentView)
    }
    
    private func setupVisibilityButton() {
        if Client.providers.tileProvider.visibleTiles.contains(tileType) {
            accessoryButtonLeft.setImage(Theme.current.activeEyeImage(), for: .normal)
            accessoryButtonLeft.setImage(Theme.current.inactiveEyeImage(), for: .highlighted)
            accessoryButtonLeft.accessibilityLabel = L10n.Tiles.Accessibility.Visible.Tile.action
        } else {
            accessoryButtonLeft.setImage(Theme.current.inactiveEyeImage(), for: .normal)
            accessoryButtonLeft.setImage(Theme.current.activeEyeImage(), for: .highlighted)
            accessoryButtonLeft.accessibilityLabel = L10n.Tiles.Accessibility.Invisible.Tile.action
        }
    }

    @IBAction private func changeTileVisibility() {
        var visibleTiles = Client.providers.tileProvider.visibleTiles
        if Client.providers.tileProvider.visibleTiles.contains(tileType) {
            let tiles = visibleTiles.filter { $0 != tileType }
            Client.providers.tileProvider.visibleTiles = tiles
        } else {
            visibleTiles.append(tileType)
            Client.providers.tileProvider.visibleTiles = visibleTiles
        }
        Macros.postNotification(.PIATilesDidChange)
    }
    
}
