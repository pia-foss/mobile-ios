//
//  SignupFailureViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

class SignupFailureViewController: AutolayoutViewController {
    @IBOutlet private weak var imvPicture: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var buttonSubmit: ActivityButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        imvPicture.image = Asset.imageAccountFailed.image
        labelTitle.text = L10n.Signup.Failure.title
        labelMessage.text = L10n.Signup.Failure.message
        buttonSubmit.title = L10n.Signup.Failure.submit.uppercased()
    }

    @IBAction private func submit() {
        perform(segue: StoryboardSegue.Signup.unwindFailureSegueIdentifier)
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyBody1(labelMessage, appearance: .dark)
        Theme.current.applyActionButton(buttonSubmit)
    }
}
