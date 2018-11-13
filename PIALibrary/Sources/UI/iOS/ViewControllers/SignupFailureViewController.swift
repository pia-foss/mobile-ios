//
//  SignupFailureViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
        perform(segue: StoryboardSegue.Signup.unwindFailureSegueIdentifier)
    }

    // MARK: Restylable
    
    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyLightBackground(view)
        Theme.current.applyLightBackground(viewContainer!)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
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
