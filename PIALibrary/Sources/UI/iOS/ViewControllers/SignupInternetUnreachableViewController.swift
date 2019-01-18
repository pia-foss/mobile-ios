//
//  SignupUnreachableViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

public class SignupUnreachableViewController: AutolayoutViewController, BrandableNavigationBar {

    @IBOutlet private weak var imvPicture: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelMessage: UILabel!
    @IBOutlet private weak var buttonSubmit: PIAButton!

    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        title = L10n.Signup.Unreachable.vcTitle
        imvPicture.image = Asset.imageNoInternet.image
        labelTitle.text = L10n.Signup.Unreachable.title
        labelMessage.text = L10n.Signup.Unreachable.message
        self.styleSubmitButton()

    }
    
    @IBAction private func submit() {
        perform(segue: StoryboardSegue.Signup.unwindInternetUnreachableSegueIdentifier)
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
        buttonSubmit.setTitle(L10n.Signup.Unreachable.submit.uppercased(),
                              for: [])
    }

}
