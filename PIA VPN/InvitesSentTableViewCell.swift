//
//  InvitesSentTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class InvitesSentTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accessoryImageRight: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.text = "View invites sent"
        self.accessoryImageRight.image = Asset.Piax.Tiles.openTileDetails.image.withRenderingMode(.alwaysTemplate)
        self.accessoryImageRight.tintColor = UIColor.piaGrey4

        Theme.current.applySecondaryBackground(self)
        Theme.current.applySecondaryBackground(self.contentView)
        Theme.current.applySettingsCellTitle(titleLabel, appearance: .dark)

    }

}
