//
//  IPTileCollectionViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class IPTileCollectionViewCell: UICollectionViewCell, TileableCell {
    
    typealias Entity = IPTile
    @IBOutlet private weak var tile: Entity!
    @IBOutlet private weak var accessoryImageRight: UIImageView!
    @IBOutlet private weak var accessoryButtonLeft: UIButton!
    @IBOutlet weak var tileLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tileRightConstraint: NSLayoutConstraint!

    func setupCellForStatus(_ status: TileStatus) {
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: {
            switch status {
            case .normal:
                self.tileLeftConstraint.constant = 0
                self.tileRightConstraint.constant = 0
            case .edit:
                self.tileLeftConstraint.constant = 55
                self.tileRightConstraint.constant = 55
            }
            self.layoutIfNeeded()
        })
    }
    
}
