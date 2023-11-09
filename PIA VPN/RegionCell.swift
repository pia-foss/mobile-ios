//
//  RegionCell.swift
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

public enum RegionStatus {
    case available
    case offline
}

class RegionCell: UITableViewCell, Restylable {
    
    @IBOutlet private weak var imvFlag: UIImageView!

    @IBOutlet private weak var labelRegion: UILabel!

    @IBOutlet private weak var labelPingTime: UILabel!
    
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var favoriteImageView: UIImageView!
    @IBOutlet private weak var leftIconImageView: UIImageView!
    @IBOutlet private weak var rightIconImageView: UIImageView!

    private var isFavorite: Bool!
    private var iconSelected = false
    private weak var server: Server!

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func fill(withServer server: Server, isSelected: Bool) {
        viewShouldRestyle()
        
        self.server = server
        setupServerAvailability()
        
        imvFlag.setImage(fromServer: server)

        labelRegion.text = server.name
        
        iconSelected = isSelected
        prepareCellIcons()

        accessibilityIdentifier = "uitests.regions.region_name"
        
        self.setSelected(false, animated: false)
    }

    private func prepareCellIcons() {
        guard let server = server else {
            return
        }
        let suffix = iconSelected ? "-selected" : ""
        if server.geo {
            leftIconImageView.image = UIImage(named: Theme.current.geoImageName()+suffix)
            rightIconImageView.image = UIImage(named: "region-selected")
            leftIconImageView.isHidden = false
            rightIconImageView.isHidden = !iconSelected
        } else {
            leftIconImageView.image = UIImage(named: "region-selected")
            rightIconImageView.image = UIImage(named: Theme.current.geoImageName()+suffix)
            leftIconImageView.isHidden = !iconSelected
            rightIconImageView.isHidden = true
        }
    }
    
    private func setupServerAvailability() {
        if server.offline == false {

            imvFlag.alpha = 1.0
            labelRegion.alpha = 1.0
            leftIconImageView.alpha = 1.0
            rightIconImageView.alpha = 1.0
            
            var pingTimeString: String?
            if let pingTime = server.pingTime {
                pingTimeString = "\(pingTime)ms"

                Theme.current.applyPingTime(labelPingTime, time: pingTime)
            }
            labelPingTime.text = pingTimeString

            if let pingTimeString = pingTimeString {
                accessibilityLabel = "\(server.name), \(pingTimeString)"
            } else {
                accessibilityLabel = server.name
            }
            
            if !self.server.isAutomatic {
                self.favoriteImageView.image = self.favoriteImageView.image?.withRenderingMode(.alwaysTemplate)
                self.isFavorite = server.isFavorite
                self.updateFavoriteImage()
                favoriteButton.isUserInteractionEnabled = true
            } else {
                self.favoriteImageView.image = nil
                self.isFavorite = true
                favoriteButton.isUserInteractionEnabled = false
            }
            
            self.isUserInteractionEnabled = true

        } else {

            imvFlag.alpha = 0.3
            labelRegion.alpha = 0.3
            leftIconImageView.alpha = 0.3
            rightIconImageView.alpha = 0.3
            labelPingTime.text = ""
            labelPingTime.accessibilityLabel = ""
            updateOfflineImage()
            favoriteButton.isUserInteractionEnabled = false
            self.isUserInteractionEnabled = false

        }
        
    }

    // MARK: Restylable

    func viewShouldRestyle() {
        
        Theme.current.applyRegionSolidLightBackground(self)
        Theme.current.applyRegionSolidLightBackground(self.contentView)

        Theme.current.applySettingsCellTitle(labelRegion, appearance: .dark)
        Theme.current.applyTag(labelPingTime, appearance: .dark)
        Theme.current.applyFavoriteUnselectedImage(self.favoriteImageView)
        
        if Theme.current.palette.appearance! == .dark {
            self.favoriteImageView.tintColor = UIColor.piaGrey10
        }
        
        prepareCellIcons()
        
    }
    
    @IBAction func favoriteServer(_ sender: UIButton) {
        self.isFavorite = !self.isFavorite
        self.isFavorite ? self.server.favorite() : self.server.unfavorite()
        self.animateFavoriteImage()
        Macros.postNotification(.PIAServerHasBeenUpdated)
    }
    
    private func animateFavoriteImage() {
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: {
            self.favoriteImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                self.updateFavoriteImage()
                self.favoriteImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        })
    }
    
    private func updateFavoriteImage() {
        self.isFavorite ?
            self.favoriteImageView.image = Asset.Piax.Global.favoriteSelected.image :
            Theme.current.applyFavoriteUnselectedImage(self.favoriteImageView)
        favoriteButton.accessibilityLabel = self.isFavorite ?
            L10n.Region.Accessibility.favorite :
            L10n.Region.Accessibility.unfavorite
    }
    
    private func updateOfflineImage() {
        self.favoriteImageView.image = Asset.offlineServerIcon.image
        self.favoriteButton.accessibilityLabel = L10n.Global.disabled
    }

}
