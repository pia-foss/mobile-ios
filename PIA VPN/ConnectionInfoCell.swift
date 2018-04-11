//
//  ConnectionInfoCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class ConnectionInfoCell: UITableViewCell, Restylable {
    @IBOutlet private weak var imvRegion: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var labelDescription: UILabel!
    
    @IBOutlet private weak var activityPending: UIActivityIndicatorView!

    @IBOutlet private weak var constraintDescriptionOffset: NSLayoutConstraint!

    func fill(withTitle title: String, description: String?) {
        doFill(withTitle: title, description: description)

        imvRegion.isHidden = true
        constraintDescriptionOffset.constant = 0.0
        layoutIfNeeded()
    }
    
    func fill(withTitle title: String, server: Server, status: VPNStatus) {
        doFill(withTitle: title, description: server.name(forStatus: status))
    
        imvRegion.setImage(fromServer: server.flagServer(forStatus: status))
        imvRegion.isHidden = false
        constraintDescriptionOffset.constant = 50.0
        layoutIfNeeded()
    }

    private func doFill(withTitle title: String, description: String?) {
        viewShouldRestyle()
        labelTitle.text = title
        
        if let description = description {
            labelDescription.text = description
            activityPending.stopAnimating()
        } else {
            labelDescription.text = nil
            activityPending.startAnimating()
        }
    }

    // MARK: Restylable
    
    func viewShouldRestyle() {
        Theme.current.applySolidLightBackground(self)
        Theme.current.applyCaption(labelTitle, appearance: .dark)
        Theme.current.applyTitle(labelDescription, appearance: .dark)
    }
}
