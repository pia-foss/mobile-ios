//
//  GDPRViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 08/03/2019.
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

public protocol GDPRDelegate: class {
    
    func gdprViewWasAccepted()

    func gdprViewWasRejected()
    
}

class GDPRViewController: AutolayoutViewController {

    @IBOutlet private weak var labelCollectTitle: UILabel!
    @IBOutlet private weak var labelCollectDescription: UILabel!
    @IBOutlet private weak var labelUseDataDescription: UILabel!

    @IBOutlet private weak var acceptButton: PIAButton!
    @IBOutlet private weak var closeButton: UIButton!

    weak var delegate: GDPRDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelCollectTitle.text = L10n.Welcome.Gdpr.Collect.Data.title
        self.labelCollectDescription.text = L10n.Welcome.Gdpr.Collect.Data.description
        self.labelUseDataDescription.text = L10n.Welcome.Gdpr.Usage.Data.description
        self.acceptButton.setTitle(L10n.Welcome.Gdpr.Accept.Button.title, for: [])
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelCollectTitle, appearance: .dark)
        Theme.current.applySubtitle(labelCollectDescription)
        Theme.current.applySubtitle(labelUseDataDescription)

        acceptButton.setRounded()
        acceptButton.style(style: TextStyle.Buttons.piaGreenButton)
        
    }
    
    @IBAction func accept(_ sender: Any) {
        if let delegate = delegate {
            delegate.gdprViewWasAccepted()
        }
        dismissModal()
    }
    
    @IBAction func reject(_ sender: Any) {
        if let delegate = delegate {
            delegate.gdprViewWasRejected()
        }
        dismissModal()
    }
    
}
