//
//  DedicatedRegionCell.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 15/10/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit
import PIALibrary

class DedicatedRegionCell: UITableViewCell, Restylable {
    
    @IBOutlet private weak var imvFlag: UIImageView!

    @IBOutlet private weak var labelRegion: UILabel!
    @IBOutlet private weak var labelIP: UILabel!
    @IBOutlet private weak var labelDedicatedIPTitle: UILabel!
    @IBOutlet private weak var viewIP: UIView!

    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var favoriteImageView: UIImageView!
    @IBOutlet private weak var leftIconImageView: UIImageView!

    private var isFavorite: Bool!
    private var iconSelected = false
    private weak var server: Server!

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func fill(withServer server: Server, isSelected: Bool) {
                
        configureIPView()
        viewShouldRestyle()
        self.server = server

        imvFlag.setImage(fromServer: server)
        
        if let _ = Client.providers.serverProvider.regionStaticData {
            labelRegion.text = Client.providers.serverProvider.regionStaticData.localisedServerName(forCountryName: server.name)
        } else {
            labelRegion.text = server.name
        }
        
        labelIP.text = server.wireGuardAddressesForUDP?.first?.ip ?? ""
        labelDedicatedIPTitle.text = L10n.Dedicated.Ip.title.uppercased()

        iconSelected = isSelected
        
        prepareCellIcons()
        accessibilityIdentifier = "uitests.regions.region_name"
        
        self.favoriteImageView.image = self.favoriteImageView.image?.withRenderingMode(.alwaysTemplate)

        self.isFavorite = server.isFavorite
        self.updateFavoriteImage()
        
        self.setSelected(false, animated: false)
    }

    private func prepareCellIcons() {
        leftIconImageView.image = UIImage(named: "region-selected")
        leftIconImageView.isHidden = !iconSelected
    }
    
    private func configureIPView() {
        viewIP.layer.cornerRadius = 10.0
        viewIP.layer.borderWidth = 0.5
        viewIP.layer.borderColor = UIColor.piaGrey4.cgColor
    }
    // MARK: Restylable

    func viewShouldRestyle() {
        
        Theme.current.applyRegionSolidLightBackground(self)
        Theme.current.applyRegionSolidLightBackground(self.contentView)
        Theme.current.applyRegionSolidLightBackground(self.viewIP)

        Theme.current.applySettingsCellTitle(labelRegion, appearance: .dark)
        Theme.current.applyRegionIPCell(labelIP, appearance: .dark)
        Theme.current.applyRegionIPTitleCell(labelDedicatedIPTitle, appearance: .dark)
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
}
