//
//  TermsAndConditionsViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 08/08/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: AutolayoutViewController, BrandableNavigationBar {

    @IBOutlet private weak var termsTitleLabel: UILabel!
    @IBOutlet private weak var termsLabel: UILabel!
    var termsAndConditionsTitle: String!
    var termsAndConditions: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.termsTitleLabel.text = self.termsAndConditionsTitle
        self.termsLabel.text = self.termsAndConditions
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Theme.current.palette.navigationBarBackIcon?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(back(_:))
        )
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Welcome.Redeem.Accessibility.back
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyBigTitle(termsTitleLabel, appearance: .dark)
        Theme.current.applySmallSubtitle(termsLabel)
    }

}
