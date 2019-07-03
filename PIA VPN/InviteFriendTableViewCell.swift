//
//  InviteFriendTableViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class InviteFriendTableViewCell: UITableViewCell {

    @IBOutlet private weak var labelFullName: UILabel!
    
    @IBOutlet private weak var textFullName: BorderedTextField!

    @IBOutlet private weak var labelEmail: UILabel!
    
    @IBOutlet private weak var textEmail: BorderedTextField!
    
    @IBOutlet private weak var textAgreement: UITextView!

    @IBOutlet private weak var sendButton: PIAButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelFullName.text = "Full name"
        labelEmail.text = "Email address"
        textAgreement.attributedText = Theme.current.agreementText(
            withMessage: "I agree to all of the terms and conditions of the Family and Friends Referral Program.",
            tos: "Family and Friends Referral Program",
            tosUrl: "https://www.privateinternetaccess.com/pages/invites/terms_and_conditions",
            privacy: "",
            privacyUrl: "")
        sendButton.setTitle("SEND INVITE",
                              for: [])

        Theme.current.applySecondaryBackground(self)
        Theme.current.applySecondaryBackground(self.contentView)
        Theme.current.applySubtitle(labelFullName)
        Theme.current.applySubtitle(labelEmail)
        Theme.current.applyInput(textFullName)
        Theme.current.applyInput(textEmail)
        Theme.current.applyLinkAttributes(textAgreement)
        sendButton.setRounded()
        sendButton.style(style: TextStyle.Buttons.piaGreenButton)
        
        textEmail.delegate = self
        textFullName.delegate = self

    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.endEditing(true)
    }

}

extension InviteFriendTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
