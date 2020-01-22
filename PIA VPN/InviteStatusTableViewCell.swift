//
//  InviteStatusTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 04/07/2019.
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

class InviteStatusTableViewCell: UITableViewCell{

    @IBOutlet private weak var emailTitleLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var signedupTitleLabel: UILabel!
    @IBOutlet private weak var signedupLabel: UILabel!
    @IBOutlet private weak var rewardedTitleLabel: UILabel!
    @IBOutlet private weak var rewardedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        emailTitleLabel.text = L10n.Account.Email.placeholder
        signedupTitleLabel.text = L10n.Friend.Referrals.signedup
        rewardedTitleLabel.text = L10n.Friend.Referrals.Reward.given
    }

    func setupCell(withInvite invite: Invites) {
        Theme.current.applySubtitle(emailTitleLabel)
        Theme.current.applySettingsCellTitle(emailLabel, appearance: .dark)
        Theme.current.applySubtitle(signedupTitleLabel)
        Theme.current.applySettingsCellTitle(signedupLabel, appearance: .dark)
        Theme.current.applySubtitle(rewardedTitleLabel)
        Theme.current.applySettingsCellTitle(rewardedLabel, appearance: .dark)
        emailLabel.text = invite.obfuscatedEmail
        signedupLabel.text = invite.accepted ? L10n.Global.yes : L10n.Global.no
        rewardedLabel.text = invite.rewarded ? L10n.Global.yes : L10n.Global.no
        
    }
    
}
