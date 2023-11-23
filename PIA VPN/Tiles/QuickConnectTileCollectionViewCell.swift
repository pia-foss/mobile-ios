//
//  QuickConnectTileCollectionViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 10/01/2019.
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

class QuickConnectTileCollectionViewCell: UICollectionViewCell, TileableCell, ServerSelectingCell {
    
    var tileType: AvailableTiles = .quickConnect

    typealias Entity = QuickConnectTile
    @IBOutlet private weak var tile: Entity!
    @IBOutlet weak var accessoryImageRight: UIImageView!
    @IBOutlet weak var accessoryButtonLeft: UIButton!
    @IBOutlet weak var tileLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tileRightConstraint: NSLayoutConstraint!
    
    weak var delegate: ServerSelectionDelegate? {
        get {
            tile.delegate
        }
        set {
            tile.delegate = newValue
        }
    }
    
    private var currentTileStatus: TileStatus?

    func setupCellForStatus(_ status: TileStatus) {
        Theme.current.applyPrincipalBackground(self)
        Theme.current.applyPrincipalBackground(self.contentView)
        self.accessoryImageRight.image = Theme.current.dragDropImage()
        tile.status = status
        let animationDuration = currentTileStatus != nil ? AppConfiguration.Animations.duration : 0
        UIView.animate(withDuration: animationDuration, animations: {
            switch status {
            case .normal:
                self.tileLeftConstraint.constant = 0
                self.tileRightConstraint.constant = 0
                self.accessoryButtonLeft.isHidden = true
            case .edit:
                self.accessoryButtonLeft.isHidden = false
                self.tileLeftConstraint.constant = self.leftConstraintValue
                self.tileRightConstraint.constant = self.rightConstraintValue
                self.setupVisibilityButton()
            }
            self.layoutIfNeeded()
            self.currentTileStatus = status
        })
    }
    
    private func setupVisibilityButton() {
        if Client.providers.tileProvider.visibleTiles.contains(tileType) {
            accessoryButtonLeft.setImage(Theme.current.activeEyeImage(), for: .normal)
            accessoryButtonLeft.setImage(Theme.current.inactiveEyeImage(), for: .highlighted)
            accessoryButtonLeft.accessibilityLabel = L10n.Localizable.Tiles.Accessibility.Visible.Tile.action
        } else {
            accessoryButtonLeft.setImage(Theme.current.inactiveEyeImage(), for: .normal)
            accessoryButtonLeft.setImage(Theme.current.activeEyeImage(), for: .highlighted)
            accessoryButtonLeft.accessibilityLabel = L10n.Localizable.Tiles.Accessibility.Invisible.Tile.action
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
