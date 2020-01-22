//
//  TermsAndConditionsViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 08/08/2019.
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

class TermsAndConditionsViewController: AutolayoutViewController, BrandableNavigationBar {

    @IBOutlet private weak var termsTitleLabel: UILabel!
    @IBOutlet private weak var termsLabel: UILabel!
    var termsAndConditionsTitle: String!
    var termsAndConditions: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.modalPresentationStyle = .automatic
        }
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

    @IBAction func close(_ sender: Any) {
        dismissModal()
    }
}
