//
//  DaysAcquiredTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 04/07/2019.
//  Copyright © 2020 Private Internet Access Inc.
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

class DaysAcquiredTableViewCell: UITableViewCell, FriendReferralCell {

    let textStyleDays = TextStyle(
        font: UIFont.regularFontWith(size: 20),
        color: Theme.current.palette.appearance == .light ? UIColor.piaGrey6 : .white,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 24
    )

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelDays: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.text = L10n.Friend.Referrals.Days.acquired
    }
    
    func setupCell(withInviteInformation inviteInformation: InvitesInformation) {
        Theme.current.applySubtitle(labelTitle)
        labelDays.style(style: textStyleDays)
        labelDays.text = L10n.Friend.Referrals.Days.number(inviteInformation.totalFreeDaysGiven)
    }

}
