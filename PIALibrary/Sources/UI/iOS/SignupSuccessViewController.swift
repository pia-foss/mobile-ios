//
//  SignupSuccessViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import SwiftyBeaver

private let log = SwiftyBeaver.self

class SignupSuccessViewController: AutolayoutViewController {
    @IBOutlet private weak var imvBackground: UIImageView!

    @IBOutlet private weak var imvPicture: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var labelUsernameCaption: UILabel!

    @IBOutlet private weak var labelUsername: UILabel!
    
    @IBOutlet private weak var labelPasswordCaption: UILabel!
    
    @IBOutlet private weak var labelPassword: UILabel!

    @IBOutlet private weak var buttonSubmit: ActivityButton!
    
    var metadata: SignupMetadata?
    
    weak var completionDelegate: WelcomeCompletionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metadata = metadata else {
            fatalError("Metadata not set")
        }

        title = metadata.title
        imvPicture.image = metadata.bodyImage
        labelTitle.text = metadata.bodyTitle
        labelMessage.text = metadata.bodySubtitle

        navigationItem.hidesBackButton = true

        labelUsernameCaption.text = L10n.Signup.Success.Username.caption
        labelUsername.text = metadata.user?.credentials.username
        labelPasswordCaption.text = L10n.Signup.Success.Password.caption
        labelPassword.text = metadata.user?.credentials.password
        buttonSubmit.title = L10n.Signup.Success.submit.uppercased()

        var backgroundImage = Asset.imageReceiptBackground.image
        backgroundImage = backgroundImage.withRenderingMode(.alwaysTemplate)
        backgroundImage = backgroundImage.resizableImage(
            withCapInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 60.0, right: 0.0),
            resizingMode: .tile
        )
        imvBackground.contentMode = .scaleToFill
        imvBackground.image = backgroundImage
    }
    
    @IBAction private func submit() {
        guard let user = metadata?.user else {
            fatalError("User account not set in metadata")
        }
        completionDelegate?.welcomeDidSignup(withUser: user, topViewController: self)
    }

    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()

        Theme.current.applyLightTint(imvBackground)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyBody1(labelMessage, appearance: .dark)
        Theme.current.applyCaption(labelUsernameCaption, appearance: .dark)
        Theme.current.applyBody1(labelUsername, appearance: .dark)
        Theme.current.applyCaption(labelPasswordCaption, appearance: .dark)
        Theme.current.applyBody1(labelPassword, appearance: .dark)
        Theme.current.applyActionButton(buttonSubmit)
    }
}
