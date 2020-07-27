//
//  NetworkManagementToolTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 22/02/2019.
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
import Reachability

class NetworkManagementToolTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal
    
    @IBOutlet private weak var tileTitleLabel: UILabel!
    @IBOutlet private weak var networkLabel: UILabel!
    @IBOutlet private weak var statusButton: UIButton!

    private var hotspotHelper: PIAHotspotHelper!
    private var reachability:Reachability!
    
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
        self.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    
    func hasDetailView() -> Bool {
        return true
    }
    
    private func setupView() {
        
        self.reachability = Reachability()
        try? reachability?.startNotifier()
        
        self.hotspotHelper = PIAHotspotHelper()
        self.detailSegueIdentifier = StoryboardSegue.Main.networkManagementToolTileSegue.rawValue
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateNetwork), name: .PIADaemonsDidUpdateConnectivity, object: nil)
        nc.addObserver(self, selector: #selector(updateNetwork), name: .PIASettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(updateNetwork), name: Notification.Name.reachabilityChanged, object: nil)

        viewShouldRestyle()
        self.tileTitleLabel.text = L10n.Settings.Hotspothelper.title.uppercased()
    }
    
    @objc private func viewShouldRestyle() {
        tileTitleLabel.style(style: TextStyle.textStyle21)
        Theme.current.applyPrincipalBackground(self)
        Theme.current.applySettingsCellTitle(networkLabel, appearance: .dark)
        
        updateNetwork()

    }
    
    @objc private func updateNetwork() {
        
        if Client.preferences.nmtRulesEnabled {
            statusButton.isUserInteractionEnabled = true
            if let ssid = hotspotHelper.currentWiFiNetwork() {
                networkLabel.text = ssid.uppercased()
                if Client.preferences.useWiFiProtection {
                    if Client.preferences.trustedNetworks.contains(ssid) ||
                        true {
                        statusButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.trustedLightIcon.image :
                            Asset.Piax.Global.trustedDarkIcon.image, for: [])
                        statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.trusted
                    } else {
                        statusButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.untrustedLightIcon.image :
                            Asset.Piax.Global.untrustedDarkIcon.image, for: [])
                        statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.untrusted
                    }
                } else {
                    statusButton.isUserInteractionEnabled = false
                    statusButton.setImage(nil, for: [])
                    statusButton.accessibilityLabel = nil
                }
            } else {
                networkLabel.text = L10n.Tiles.Nmt.cellular
                if Client.preferences.trustCellularData {
                    statusButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.untrustedLightIcon.image :
                        Asset.Piax.Global.untrustedDarkIcon.image, for: [])
                    statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.untrusted
                } else {
                    statusButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.trustedLightIcon.image :
                        Asset.Piax.Global.trustedDarkIcon.image, for: [])
                    statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.trusted
                }
            }
        } else { // if NMT disabled
            statusButton.isUserInteractionEnabled = false
            networkLabel.text = L10n.Global.disabled
            statusButton.setImage(nil, for: [])
            statusButton.accessibilityLabel = L10n.Global.disabled
        }
        
    }

    @IBAction func changeNetworkTrustMode(_ sender: Any) {
        if let ssid = hotspotHelper.currentWiFiNetwork() { //wifi
            if Client.preferences.useWiFiProtection {
                if Client.preferences.trustedNetworks.contains(ssid) {
                    hotspotHelper.removeTrustedNetwork(ssid)
                } else {
                    hotspotHelper.saveTrustedNetwork(ssid)
                }
                statusButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.trustedLightIcon.image :
                    Asset.Piax.Global.trustedDarkIcon.image, for: [])
            }
        } else { // cellular
            let preferences = Client.preferences.editable()
            preferences.trustCellularData = !Client.preferences.trustCellularData
            preferences.commit()
        }
        updateProfile()
        updateNetwork()
    }
    
    private func updateProfile() {
        NotificationCenter.default.post(name: .PIASettingsHaveChanged,
                                        object: self,
                                        userInfo: nil)
    }
    
}
