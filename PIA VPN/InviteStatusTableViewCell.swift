//
//  InviteStatusTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 04/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class InviteStatusTableViewCell: UITableViewCell, FriendReferralCell {

    @IBOutlet private weak var emailTitleLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var openedTitleLabel: UILabel!
    @IBOutlet private weak var openedLabel: UILabel!
    @IBOutlet private weak var signedupTitleLabel: UILabel!
    @IBOutlet private weak var signedupLabel: UILabel!
    @IBOutlet private weak var rewardedTitleLabel: UILabel!
    @IBOutlet private weak var rewardedLabel: UILabel!
    @IBOutlet private weak var actionButton: PIAButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        emailTitleLabel.text = "Email address"
        emailLabel.text = "a@a.com"
        openedTitleLabel.text = "Opened"
        openedLabel.text = "Yes"
        signedupTitleLabel.text = "Signed up"
        signedupLabel.text = "No"
        rewardedTitleLabel.text = "Reward given"
        rewardedLabel.text = "No"
        actionButton.setTitle("Resend", for: .normal)
    }

    func setupCell() {
        Theme.current.applySubtitle(emailTitleLabel)
        Theme.current.applySettingsCellTitle(emailLabel, appearance: .dark)
        Theme.current.applySubtitle(openedTitleLabel)
        Theme.current.applySettingsCellTitle(openedLabel, appearance: .dark)
        Theme.current.applySubtitle(signedupTitleLabel)
        Theme.current.applySettingsCellTitle(signedupLabel, appearance: .dark)
        Theme.current.applySubtitle(rewardedTitleLabel)
        Theme.current.applySettingsCellTitle(rewardedLabel, appearance: .dark)
        Theme.current.applyTransparentButton(actionButton,
                                             withSize: 0)
    }
    
    @IBAction func sendInvite() {
        self.isUserInteractionEnabled = false
        self.showLoadingAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.hideLoadingAnimation()
            self.isUserInteractionEnabled = true
            Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                    message: "Could not resend invite. Try again later.")
        }

    }
}
