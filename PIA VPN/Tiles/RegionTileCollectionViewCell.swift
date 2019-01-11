//
//  RegionTileCollectionViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit

class RegionTileCollectionViewCell: UICollectionViewCell, TileableCell {
    
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
        UIView.animate(withDuration: 0.3, animations: {
            switch status {
            case .normal:
                self.tileLeftConstraint.constant = 0
            case .edit:
                self.tileLeftConstraint.constant = 55
            }
            self.layoutIfNeeded()
        })
    }
    
}
