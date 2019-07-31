//
//  DaysAcquiredTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 04/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
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
