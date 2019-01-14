//
//  RegionTileCollectionViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class RegionTileCollectionViewCell: UICollectionViewCell, TileableCell {
    
    var tileType: AvailableTiles = .region

    typealias Entity = RegionTile
    @IBOutlet private weak var tile: Entity!
    @IBOutlet private weak var accessoryImageRight: UIImageView!
    @IBOutlet private weak var accessoryButtonLeft: UIButton!

    @IBOutlet weak var tileLeftConstraint: NSLayoutConstraint!
    
    func hasDetailView() -> Bool {
        return tile.hasDetailView()
    }
    
    func segueIdentifier() -> String? {
        return tile.detailSegueIdentifier
    }
    
    func setupCellForStatus(_ status: TileStatus) {
        Theme.current.applySolidLightBackground(self)
        Theme.current.applySolidLightBackground(self.contentView)
        tile.status = status
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: {
            switch status {
            case .normal:
                self.accessoryImageRight.image = Asset.Piax.Tiles.openTileDetails.image
                self.tileLeftConstraint.constant = 0
            case .edit:
                self.accessoryImageRight.image = Theme.current.dragDropImage()
                self.tileLeftConstraint.constant = 34
                self.setupVisibilityButton()
            }
            self.layoutIfNeeded()
        })
    }
    
    
    func highlightCell() {
        Theme.current.applyLightBackground(tile)
        Theme.current.applyLightBackground(self)
        Theme.current.applyLightBackground(self.contentView)
    }
    
    func unhighlightCell() {
        Theme.current.applySolidLightBackground(tile)
        Theme.current.applySolidLightBackground(self)
        Theme.current.applySolidLightBackground(self.contentView)
    }
    
    private func setupVisibilityButton() {
        if Client.providers.tileProvider.visibleTiles.contains(tileType) {
            accessoryButtonLeft.setImage(Theme.current.activeEyeImage(), for: .normal)
            accessoryButtonLeft.setImage(Theme.current.inactiveEyeImage(), for: .highlighted)
        } else {
            accessoryButtonLeft.setImage(Theme.current.inactiveEyeImage(), for: .normal)
            accessoryButtonLeft.setImage(Theme.current.activeEyeImage(), for: .highlighted)
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
        Macros.postNotification(.PIAThemeDidChange)
    }
    
}
