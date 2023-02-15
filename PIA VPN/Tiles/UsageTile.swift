//
//  UsageTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
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

import Foundation
import PIALibrary
import UIKit

class UsageTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal
    
    @IBOutlet private weak var usageTitle: UILabel!
    @IBOutlet private weak var uploadTitle: UILabel!
    @IBOutlet private weak var uploadValue: UILabel!
    @IBOutlet private weak var downloadTitle: UILabel!
    @IBOutlet private weak var downloadValue: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
        self.setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(displayUsageInformation), name: .PIAVPNUsageUpdate, object: nil)
        
        viewShouldRestyle()
        self.usageTitle.text = L10n.Tiles.Usage.title.uppercased()
        self.uploadTitle.text = L10n.Tiles.Usage.upload
        self.downloadTitle.text = L10n.Tiles.Usage.download
        displayUsageInformation()
    }
    
    @objc private func viewShouldRestyle() {
        usageTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySettingsCellTitle(uploadValue, appearance: .dark)
        Theme.current.applySettingsCellTitle(downloadValue, appearance: .dark)
        Theme.current.applySubtitleTileUsage(uploadTitle, appearance: .dark)
        Theme.current.applySubtitleTileUsage(downloadTitle, appearance: .dark)
        Theme.current.applyPrincipalBackground(self)
        displayUsageInformation()
    }
    
    @objc private func displayUsageInformation() {
        updateStyleForVPNType(Client.providers.vpnProvider.currentVPNType)
        if Client.providers.vpnProvider.currentVPNType != IKEv2Profile.vpnType {
            Client.providers.vpnProvider.dataUsage { (usage, error) in
                var uploaded = Int64(0)
                var downloaded = Int64(0)
                if error == nil,
                    let usage = usage {
                    uploaded = Int64(usage.uploaded)
                    downloaded = Int64(usage.downloaded)
                }
                self.uploadValue.text = ByteCountFormatter.string(fromByteCount: uploaded,
                                                                  countStyle: .file)
                self.downloadValue.text = ByteCountFormatter.string(fromByteCount: downloaded,
                                                                    countStyle: .file)
            }
        }
    }
    
    private func updateStyleForVPNType(_ vpnType: String) {
        if vpnType == IKEv2Profile.vpnType {
            self.uploadValue.text = ByteCountFormatter.string(fromByteCount: Int64(0),
                                                              countStyle: .file)
            self.downloadValue.text = ByteCountFormatter.string(fromByteCount: Int64(0),
                                                                countStyle: .file)
            self.uploadValue.alpha = 0.2
            self.downloadValue.alpha = 0.2
            self.usageTitle.text = L10n.Tiles.Usage.Ipsec.title
        } else {
            self.usageTitle.text = L10n.Tiles.Usage.title.uppercased()
            self.uploadValue.alpha = 1
            self.downloadValue.alpha = 1
        }
    }
}
