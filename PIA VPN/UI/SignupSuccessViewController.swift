//
//  SignupSuccessViewController.swift
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

import Foundation
import SwiftyBeaver
import UIKit
import PIALibrary

private let log = SwiftyBeaver.self

public class SignupSuccessViewController: AutolayoutViewController, BrandableNavigationBar {

    @IBOutlet private weak var imvPicture: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelMessage: UILabel!
    @IBOutlet private weak var labelUsernameCaption: UILabel!
    @IBOutlet private weak var labelUsername: UILabel!
    @IBOutlet private weak var labelPasswordCaption: UILabel!
    @IBOutlet private weak var labelPassword: UILabel!
    @IBOutlet private weak var buttonSubmit: PIAButton!
    @IBOutlet private weak var usernameContainer: UIView!
    @IBOutlet private weak var passwordContainer: UIView!
    
    //Share data
    @IBOutlet private weak var shareDataContainer: UIView!
    @IBOutlet private weak var shareDataImageView: UIImageView!
    @IBOutlet private weak var shareDataTitleLabel: UILabel!
    @IBOutlet private weak var shareDataDescriptionLabel: UILabel!
    @IBOutlet private weak var readMoreButton: PIAButton!
    @IBOutlet private weak var acceptButton: PIAButton!
    @IBOutlet private weak var cancelButton: PIAButton!
    @IBOutlet private weak var shareDataFooterLabel: UILabel!

    @IBOutlet private weak var constraintPictureXOffset: NSLayoutConstraint!
    
    var metadata: SignupMetadata?
    
    weak var completionDelegate: WelcomeCompletionDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metadata = metadata else {
            fatalError("Metadata not set")
        }

        title = metadata.title
        imvPicture.image = metadata.bodyImage
        if let offset = metadata.bodyImageOffset {
            constraintPictureXOffset.constant = offset.x
        }
        labelTitle.text = metadata.bodyTitle
        labelMessage.text = metadata.bodySubtitle

        navigationItem.hidesBackButton = true

        labelUsernameCaption.text = L10n.Signup.Success.Username.caption
        labelUsername.text = metadata.user?.credentials.username
        labelPasswordCaption.text = L10n.Signup.Success.Password.caption
        labelPassword.text = metadata.user?.credentials.password

        self.styleSubmitButton()
        self.styleContainers()
                
        shareDataImageView.image = Asset.Ui.imageDocumentConsent.image
        shareDataTitleLabel.text = L10n.Signup.Share.Data.Text.title
        shareDataDescriptionLabel.text = L10n.Signup.Share.Data.Text.description
        shareDataFooterLabel.text = L10n.Signup.Share.Data.Text.footer
        self.styleShareDataButtons()
    }
    
    @IBAction private func submit() {
        guard let user = metadata?.user else {
            fatalError("User account not set in metadata")
        }
        completionDelegate?.welcomeDidSignup(withUser: user, topViewController: self)
    }
    
    @IBAction private func acceptShareData() {
        let preferences = Client.preferences.editable()
        preferences.shareServiceQualityData = true
        preferences.versionWhenServiceQualityOpted = Macros.versionString()
        preferences.commit()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.shareDataContainer.alpha = 0
            }
        }
    }
    
    @IBAction private func rejectShareData() {
        let preferences = Client.preferences.editable()
        preferences.shareServiceQualityData = false
        preferences.versionWhenServiceQualityOpted = nil
        preferences.commit()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.shareDataContainer.alpha = 0
            }
        }
    }

    // MARK: Restylable

    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(viewContainer!)
        Theme.current.applyPrincipalBackground(shareDataContainer!)

        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelMessage)

        Theme.current.applyTitle(shareDataTitleLabel, appearance: .dark)
        Theme.current.applySubtitle(shareDataDescriptionLabel)
        Theme.current.applySmallSubtitle(shareDataFooterLabel)
        Theme.current.applyTransparentButton(cancelButton,
                                             withSize: 1.0)
        Theme.current.applyButtonLabelMediumStyle(acceptButton)

        Theme.current.applySubtitle(labelUsernameCaption)
        Theme.current.applyTitle(labelUsername, appearance: .dark)
        Theme.current.applySubtitle(labelPasswordCaption)
        Theme.current.applyTitle(labelPassword, appearance: .dark)
    }
    
    private func styleSubmitButton() {
        buttonSubmit.setRounded()
        buttonSubmit.style(style: TextStyle.Buttons.piaGreenButton)
        buttonSubmit.setTitle(L10n.Signup.Success.submit.uppercased(),
                              for: [])
    }
    
    private func styleShareDataButtons() {
        acceptButton.setRounded()
        acceptButton.style(style: TextStyle.Buttons.piaGreenButton)
        acceptButton.setTitle(L10n.Signup.Share.Data.Buttons.accept.uppercased(),
                              for: [])
        cancelButton.setRounded()
        cancelButton.style(style: TextStyle.Buttons.piaPlainTextButton)
        cancelButton.setTitle(L10n.Signup.Share.Data.Buttons.noThanks.uppercased(),
                              for: [])
        Theme.current.applyTransparentButton(cancelButton,
                                             withSize: 1.0)
        readMoreButton.setTitle(L10n.Signup.Share.Data.Buttons.readMore, for: .normal)
        Theme.current.applyUnderlinedSubtitleButton(readMoreButton)
    }
    
    private func styleContainers() {
        self.styleContainerView(usernameContainer)
        self.styleContainerView(passwordContainer)
    }
    
    func styleContainerView(_ view: UIView) {
        view.layer.cornerRadius = 6.0
        view.clipsToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.piaGrey4.cgColor
    }

}
