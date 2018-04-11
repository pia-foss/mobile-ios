//
//  ContentBlockerViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 3/5/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class ContentBlockerViewController: AutolayoutViewController {
    @IBOutlet private weak var imvPicture: UIImageView!
    
    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var labelFooter: UILabel!

    @IBOutlet private weak var buttonSubmit: ActivityButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.ContentBlocker.title

        imvPicture.image = Asset.imageContentBlocker.image
        labelTitle.text = L10n.ContentBlocker.title
        labelMessage.text = L10n.ContentBlocker.Body.subtitle
        labelFooter.text = L10n.ContentBlocker.Body.footer
        buttonSubmit.title = L10n.Global.ok
    }

    @IBAction private func submit() {
        perform(segue: StoryboardSegue.Main.unwindContentBlockerSegueIdentifier)
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyBody1(labelMessage, appearance: .dark)
        Theme.current.applySmallInfo(labelFooter, appearance: .dark)
        Theme.current.applyActionButton(buttonSubmit)
    }
}
