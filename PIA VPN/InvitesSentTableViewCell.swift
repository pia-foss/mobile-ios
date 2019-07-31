//
//  InvitesSentTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class InvitesSentTableViewCell: UITableViewCell, FriendReferralCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accessoryImageRight: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        Theme.current.applySecondaryBackground(self)
        Theme.current.applySecondaryBackground(self.contentView)

    }

    func setupCell(withInviteInformation inviteInformation: InvitesInformation) {
        self.titleLabel.text = L10n.Friend.Referrals.View.Invites.sent
        Theme.current.applySettingsCellTitle(titleLabel, appearance: .dark)
    }
    
    func setupCell(withInviteInformation inviteInformation: InvitesInformation, andRow row: Int) {
        Theme.current.applySettingsCellTitle(titleLabel, appearance: .dark)
        if row == 0 {
            let count = inviteInformation.invites.filter({ !$0.rewarded }).count
            self.setupAccessoryImageVisibility(count)
            self.titleLabel.text = L10n.Friend.Referrals.Pending.invites(count)
        } else {
            let count = inviteInformation.invites.filter({ $0.rewarded }).count
            self.setupAccessoryImageVisibility(count)
            self.titleLabel.text = L10n.Friend.Referrals.Signups.number(count)
        }
    }
    
    private func setupAccessoryImageVisibility(_ count: Int) {
        if count == 0 {
            self.accessoryImageRight.image = nil
        }else {
            self.accessoryImageRight.image = Asset.Piax.Tiles.openTileDetails.image.withRenderingMode(.alwaysTemplate)
            self.accessoryImageRight.tintColor = UIColor.piaGrey4
        }
    }

}
