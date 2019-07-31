//
//  InviteStatusTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 04/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
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
