//
//  NetworkManagementToolTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 22/02/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
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
        if let ssid = hotspotHelper.currentWiFiNetwork() {
            networkLabel.text = ssid.uppercased()
            if Client.preferences.useWiFiProtection {
                if Client.preferences.trustedNetworks.contains(ssid) {
                    statusButton.setImage(Asset.Piax.Global.trustedIcon.image, for: [])
                    statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.trusted
                } else {
                    statusButton.setImage(Asset.Piax.Global.untrustedIcon.image, for: [])
                    statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.untrusted
                }
            } else {
                statusButton.setImage(nil, for: [])
                statusButton.accessibilityLabel = nil
            }
        } else {
            networkLabel.text = L10n.Tiles.Nmt.cellular
            if Client.preferences.trustCellularData {
                statusButton.setImage(Asset.Piax.Global.trustedIcon.image, for: [])
                statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.trusted
            } else {
                statusButton.setImage(Asset.Piax.Global.untrustedIcon.image, for: [])
                statusButton.accessibilityLabel = L10n.Tiles.Nmt.Accessibility.untrusted
            }
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
                statusButton.setImage(Asset.Piax.Global.trustedIcon.image, for: [])
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
