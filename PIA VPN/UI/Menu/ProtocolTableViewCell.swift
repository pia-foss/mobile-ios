//
//  ProtocolTableViewCell.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 11/03/2020.
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

class ProtocolTableViewCell: UITableViewCell {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var labelPromotion: UILabel!
    @IBOutlet weak var labelDescriptionRightConstraint: NSLayoutConstraint!

    func setupCell(withTitle title: String, description: String, shouldShowBadge showBadge: Bool = false) {

        labelPromotion.alpha = CGFloat(showBadge.intValue)
        labelTitle.text = title
        labelDescription.text = description
        labelPromotion.text = ""
        labelDescriptionRightConstraint.constant = 0
        if showBadge {
            labelPromotion.text = " PREVIEW "
            labelDescriptionRightConstraint.constant = 8
        }
        
        Theme.current.applyBadgeStyle(labelPromotion)
        Theme.current.applySettingsCellTitle(labelTitle,
                                             appearance: .dark)
        labelTitle.backgroundColor = .clear

        Theme.current.applySubtitle(labelDescription)
        labelDescription.backgroundColor = .clear


    }


}
