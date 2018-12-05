//
//  ExpirationCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class ExpirationCell: UITableViewCell, Restylable {
    @IBOutlet private weak var labelWarning: UILabel!
    
    @IBOutlet private weak var labelUpgrade: UILabel!
    
    @IBOutlet private weak var imvAccessory: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelUpgrade.text = L10n.Menu.Expiration.upgrade
        imvAccessory.image = Asset.accessoryExpire.image.withRenderingMode(.alwaysTemplate)
        imvAccessory.tintColor = .white
    }

    func fill(withTimeLeft timeLeft: DateComponents) {
        viewShouldRestyle()

        let timeLeftString: String
        if let day = timeLeft.day, (day > 0) {
            timeLeftString = L10n.Menu.Expiration.days(day)
        } else if let hour = timeLeft.hour, (hour > 0) {
            timeLeftString = L10n.Menu.Expiration.hours(hour)
        } else {
            timeLeftString = L10n.Menu.Expiration.oneHour
        }
        
        let prefix = L10n.Menu.Expiration.expiresIn
        labelWarning.text = "\(prefix) \(timeLeftString)".uppercased()
    }

    // MARK: Restylable
    
    func viewShouldRestyle() {
        let backgroundView = UIView()
        self.backgroundView = backgroundView
        
        Theme.current.applyLightBackground(self)
        Theme.current.applyWarningMenuBackground(backgroundView)
        Theme.current.applyMenuCaption(labelWarning)
        Theme.current.applyMenuSmallCaption(labelUpgrade)
        labelUpgrade.textColor = .white // XXX
    }
}
