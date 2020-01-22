//
//  RegionCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2020 Private Internet Access Inc.
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

class RegionCell: UITableViewCell, Restylable {
    
    @IBOutlet private weak var imvFlag: UIImageView!

    @IBOutlet private weak var labelRegion: UILabel!

    @IBOutlet private weak var labelPingTime: UILabel!
    
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var favoriteImageView: UIImageView!
    @IBOutlet private weak var selectedRegionImageView: UIImageView!

    private var isFavorite: Bool!
    private weak var server: Server!

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func fill(withServer server: Server, isSelected: Bool) {
        viewShouldRestyle()
        self.server = server

        imvFlag.setImage(fromServer: server)
        labelRegion.text = server.name
        
        var pingTimeString: String?
        if let pingTime = server.pingTime {
            pingTimeString = "\(pingTime)ms"

            Theme.current.applyPingTime(labelPingTime, time: pingTime)
        }
        labelPingTime.text = pingTimeString
        
        selectedRegionImageView.isHidden = !isSelected
        
        if let pingTimeString = pingTimeString {
            accessibilityLabel = "\(server.name), \(pingTimeString)"
        } else {
            accessibilityLabel = server.name
        }
        accessibilityIdentifier = "uitests.regions.region_name"
        
        self.favoriteImageView.image = self.favoriteImageView.image?.withRenderingMode(.alwaysTemplate)

        self.isFavorite = server.isFavorite
        self.updateFavoriteImage()
        
        self.setSelected(false, animated: false)
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
        
    }
    
    @IBAction func favoriteServer(_ sender: UIButton) {
        self.isFavorite = !self.isFavorite
        self.isFavorite ? self.server.favorite() : self.server.unfavorite()
        self.animateFavoriteImage()
        NotificationCenter.default.post(name: .PIAServerHasBeenUpdated,
                                        object: self,
                                        userInfo: nil)
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
}
