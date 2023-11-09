//
//  ExpirationCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
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
        
        Theme.current.applyPrincipalBackground(self)
        Theme.current.applyWarningMenuBackground(backgroundView)
        Theme.current.applyMenuCaption(labelWarning)
        Theme.current.applyMenuSmallCaption(labelUpgrade)
        labelUpgrade.textColor = .white // XXX
    }
}
