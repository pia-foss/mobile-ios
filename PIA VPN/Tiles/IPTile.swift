//
//  IPTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class IPTile: UIView, Tileable  {
    
    var detailViewAction: Func!
    var view: UIView!
    var detailSegueIdentifier: String!

    @IBOutlet private weak var localIpTitle: UILabel!
    @IBOutlet private weak var localIpValue: UILabel!
    @IBOutlet private weak var vpnIpTitle: UILabel!
    @IBOutlet private weak var vpnIpValue: UILabel!
    
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
        nc.addObserver(self, selector: #selector(updateCurrentIP), name: .PIADaemonsDidUpdateConnectivity, object: nil)
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)

        viewShouldRestyle()
        self.detailViewAction = {}
        self.localIpTitle.text = "IP"
        self.vpnIpTitle.text = "VPN IP"
        self.localIpValue.text = "---"
        self.vpnIpValue.text = "---"
    }
    
    @objc private func viewShouldRestyle() {
        Theme.current.applySubtitle(localIpTitle)
        Theme.current.applySubtitle(vpnIpTitle)
        Theme.current.applySubtitle(localIpValue)
        Theme.current.applySettingsCellTitle(vpnIpValue, appearance: .dark)
        Theme.current.applyLightBackground(self)
    }
    
    @objc private func updateCurrentIP() {
        self.localIpValue.text = Client.daemons.publicIP
        let vpn = Client.providers.vpnProvider
        if (vpn.vpnStatus == .connected) {
            self.vpnIpValue.text = Client.daemons.vpnIP
            self.localIpValue.text = Client.daemons.publicIP
        } else if (!Client.daemons.isInternetReachable && (vpn.vpnStatus == .disconnected)) {
            self.vpnIpValue.text = L10n.Dashboard.Connection.Ip.unreachable
            self.localIpValue.text = "---"
        } else {
            self.vpnIpValue.text = "---"
            self.localIpValue.text = "---"
        }
    }

}
