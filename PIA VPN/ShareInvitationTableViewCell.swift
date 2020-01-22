//
//  ShareInvitationTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
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

class ShareInvitationTableViewCell: UITableViewCell, FriendReferralCell {

    @IBOutlet private weak var labelDescription: UILabel!
        
    @IBOutlet private weak var textUniqueCode: BorderedTextField!

    @IBOutlet private weak var textAgreement: UITextView!
    
    @IBOutlet private weak var copyButton: PIAButton!

    @IBOutlet private weak var shareButton: PIAButton!

    @IBOutlet private weak var copiedView: UIView!
    @IBOutlet private weak var copiedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        labelDescription.text = L10n.Friend.Referrals.Share.link
        textAgreement.attributedText = Theme.current.agreementText(
            withMessage: L10n.Friend.Referrals.Share.Link.terms,
            tos: L10n.Friend.Referrals.Family.Friends.program,
            tosUrl: AppConstants.Web.friendReferralTerms,
            privacy: "",
            privacyUrl: "")
        copyButton.setTitle(L10n.Global.copy.uppercased(),
                            for: [])
        shareButton.setTitle(L10n.Global.share.uppercased(),
                             for: [])
        copiedLabel.text = L10n.Global.copied.uppercased()
        copiedView.alpha = 0
        
        Theme.current.applySecondaryBackground(self)
        Theme.current.applySecondaryBackground(self.contentView)

        copyButton.setRounded()
        copyButton.setButtonImage()
        copyButton.setImage(Asset.copyIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        copyButton.tintColor = .white
        copyButton.style(style: TextStyle.Buttons.piaGreenButton)
        shareButton.setRounded()
        shareButton.setButtonImage()
        shareButton.setImage(Asset.shareIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        shareButton.tintColor = .white
        shareButton.style(style: TextStyle.Buttons.piaGreenButton)
        
        textUniqueCode.delegate = self
        textUniqueCode.isUserInteractionEnabled = false

    }

    func setupCell(withInviteInformation inviteInformation: InvitesInformation) {
        
        Theme.current.applyInputOverlay(copiedView)
        Theme.current.applyFriendReferralsMessageLabel(copiedLabel)
        Theme.current.applySubtitle(labelDescription)
        Theme.current.applyInput(textUniqueCode)
        Theme.current.applyLinkAttributes(textAgreement)
        
        textUniqueCode.text = inviteInformation.uniqueReferralLink
        
    }
    
    @IBAction func copyToClipboard() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = textUniqueCode.text
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: { [weak self] in
            self?.copiedView.alpha = 0.75
            }, completion: { [weak self] finished in
                UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: { [weak self] in
                    self?.copiedView.alpha = 0
                })
        })

    }
    
    @IBAction func shareInApps() {
        Macros.postNotification(.ShareFriendReferralCode)
    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.endEditing(true)
    }

}

extension ShareInvitationTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
