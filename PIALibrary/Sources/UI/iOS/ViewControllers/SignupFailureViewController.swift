//
//  SignupFailureViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
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

public class SignupFailureViewController: AutolayoutViewController, BrandableNavigationBar {

    @IBOutlet private weak var imvPicture: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelMessage: UILabel!
    @IBOutlet private weak var buttonSubmit: PIAButton!
    
    var error: Error?

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        title = L10n.Signup.Failure.vcTitle
        imvPicture.image = Asset.imageAccountFailed.image
        labelTitle.text = L10n.Signup.Failure.title
        labelMessage.text = L10n.Signup.Failure.message
            
        if let clientError = error as? ClientError {
            switch clientError {
            case .redeemInvalid:
                title = L10n.Welcome.Redeem.title
                imvPicture.image = Asset.imageRedeemInvalid.image
                labelTitle.text = L10n.Signup.Failure.Redeem.Invalid.title
                labelMessage.text = L10n.Signup.Failure.Redeem.Invalid.message
                break
            case .redeemClaimed:
                title = L10n.Welcome.Redeem.title
                imvPicture.image = Asset.imageRedeemClaimed.image
                labelTitle.text = L10n.Signup.Failure.Redeem.Claimed.title
                labelMessage.text = L10n.Signup.Failure.Redeem.Claimed.message
                break
                
            default:
                break
            }
        }
        
        self.styleSubmitButton()
    }

    @IBAction private func submit() {
        dismissModal()
    }

    // MARK: Restylable
    
    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(viewContainer!)
        Theme.current.applySubtitle(labelMessage)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
    }
    
    private func styleSubmitButton() {
        buttonSubmit.setRounded()
        buttonSubmit.style(style: TextStyle.Buttons.piaGreenButton)
        buttonSubmit.setTitle(L10n.Signup.Failure.submit.uppercased(),
                              for: [])
    }

}
