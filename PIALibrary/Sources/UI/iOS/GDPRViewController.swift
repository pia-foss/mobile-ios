//
//  GDPRViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 08/03/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit

public protocol GDPRDelegate: class {
    
    func gdprViewWasAccepted()

    func gdprViewWasRejected()
    
}

class GDPRViewController: AutolayoutViewController {

    @IBOutlet private weak var labelCollectTitle: UILabel!
    @IBOutlet private weak var labelCollectDescription: UILabel!
    @IBOutlet private weak var labelUseDataTitle: UILabel!
    @IBOutlet private weak var labelUseDataDescription: UILabel!

    @IBOutlet private weak var acceptButton: PIAButton!
    @IBOutlet private weak var closeButton: UIButton!

    weak var delegate: GDPRDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelCollectTitle.text = L10n.Welcome.Gdpr.Collect.Data.title
        self.labelCollectDescription.text = L10n.Welcome.Gdpr.Collect.Data.description
        self.labelUseDataTitle.text = L10n.Welcome.Gdpr.Usage.Data.title
        self.labelUseDataDescription.text = L10n.Welcome.Gdpr.Usage.Data.description
        self.acceptButton.setTitle(L10n.Welcome.Gdpr.Accept.Button.title, for: [])
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelCollectTitle, appearance: .dark)
        Theme.current.applyTitle(labelUseDataTitle, appearance: .dark)
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
