//
//  SignupUnreachableViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

class SignupUnreachableViewController: AutolayoutViewController {
    @IBOutlet private weak var imvPicture: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var buttonSubmit: ActivityButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        title = L10n.Signup.Unreachable.vcTitle
        imvPicture.image = Asset.imageNoInternet.image
        labelTitle.text = L10n.Signup.Unreachable.title
        labelMessage.text = L10n.Signup.Unreachable.message
        buttonSubmit.title = L10n.Signup.Unreachable.submit.uppercased()
    }
    
    @IBAction private func submit() {
        perform(segue: StoryboardSegue.Signup.unwindInternetUnreachableSegueIdentifier)
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyBody1(labelMessage, appearance: .dark)
        Theme.current.applyActionButton(buttonSubmit)
    }
}
