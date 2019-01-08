//
//  RegionCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
        self.favoriteImageView.alpha = CGFloat(NSNumber(booleanLiteral: !server.isAutomatic).floatValue)
        self.favoriteButton.alpha = CGFloat(NSNumber(booleanLiteral: !server.isAutomatic).floatValue)

        self.isFavorite = server.isFavorite
        self.updateFavoriteImage()
        
        self.setSelected(false, animated: false)
    }

    // MARK: Restylable

    func viewShouldRestyle() {
        
        self.backgroundColor = Theme.current.palette.lightBackground
        self.contentView.backgroundColor = Theme.current.palette.lightBackground

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
    }
    
    private func animateFavoriteImage() {
        UIView.animate(withDuration: 0.3, animations: {
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
    }
}
