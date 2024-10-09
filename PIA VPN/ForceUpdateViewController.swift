//
//  ForceUpdateViewController.swift
//  PIA VPN
//
//  Created by Said Rehouni on 9/10/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import UIKit
import PIALibrary

class ForceUpdateViewController: UIViewController {
    @IBOutlet weak var updateButton: PIAButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        styleUpdateButton()
        
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        updateButton.setTitle("Update Now", for: .normal)
    }
    
    @objc func updateButtonTapped() {
        Client.providers.vpnProvider.uninstallAll()
        UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/private-internet-access-anonymous/id955626407")!)
    }
    
    private func styleUpdateButton() {
        updateButton.setRounded()
        updateButton.style(style: TextStyle.Buttons.piaGreenButton)
        updateButton.setTitle(L10n.Welcome.Purchase.submit.uppercased(),
                               for: [])
    }
}