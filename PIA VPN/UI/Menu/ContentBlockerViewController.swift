//
//  ContentBlockerViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 3/5/18.
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
import PIALibrary
import PIAUIKit

class ContentBlockerViewController: AutolayoutViewController {
    @IBOutlet private weak var imvPicture: UIImageView!
    
    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var labelFooter: UILabel!

    @IBOutlet private weak var buttonSubmit: ActivityButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Localizable.ContentBlocker.title
        isModalInPresentation = true
        
        imvPicture.image = Asset.Images.imageContentBlocker.image
        labelTitle.text = L10n.Localizable.ContentBlocker.title
        labelMessage.text = L10n.Localizable.ContentBlocker.Body.subtitle
        labelFooter.text = L10n.Localizable.ContentBlocker.Body.footer
        buttonSubmit.title = L10n.Localizable.Global.ok
    }

    @IBAction private func submit() {
        perform(segue: StoryboardSegue.Main.unwindContentBlockerSegueIdentifier)
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelMessage)
        Theme.current.applySmallInfo(labelFooter, appearance: .dark)
        Theme.current.applyActionButton(buttonSubmit)
    }
}
