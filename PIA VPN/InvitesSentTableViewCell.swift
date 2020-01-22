//
//  InvitesSentTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
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

class InvitesSentTableViewCell: UITableViewCell, FriendReferralCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accessoryImageRight: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        Theme.current.applySecondaryBackground(self)
        Theme.current.applySecondaryBackground(self.contentView)
        self.titleLabel.text = L10n.Friend.Referrals.View.Invites.sent

    }

    func setupCell(withInviteInformation inviteInformation: InvitesInformation) {
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
