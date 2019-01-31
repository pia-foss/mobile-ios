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
    
    private let emptyIPValue = "---"
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet {
            statusUpdated()
        }
    }

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
        nc.addObserver(self, selector: #selector(updateActivityViews), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)

        viewShouldRestyle()
        self.localIpTitle.text = "IP"
        self.vpnIpTitle.text = "VPN IP"
        self.localIpValue.text = Client.daemons.publicIP ?? emptyIPValue
        self.vpnIpValue.text = emptyIPValue
        
    }
    
    @objc private func viewShouldRestyle() {
        localIpTitle.style(style: TextStyle.textStyle21)
        vpnIpTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySettingsCellTitle(localIpValue, appearance: .dark)
        Theme.current.applySettingsCellTitle(vpnIpValue, appearance: .dark)
        Theme.current.applyPrincipalBackground(self)
    }
    
    @objc private func updateCurrentIP() {
        self.localIpValue.text = Client.daemons.publicIP
        let vpn = Client.providers.vpnProvider
        if (vpn.vpnStatus == .connected) {
            self.vpnIpValue.text = Client.daemons.vpnIP ?? self.emptyIPValue
        } else if (!Client.daemons.isInternetReachable && (vpn.vpnStatus == .disconnected)) {
            self.vpnIpValue.text = L10n.Dashboard.Connection.Ip.unreachable
        }
    }
    
    @objc private func updateActivityViews() {
        let vpn = Client.providers.vpnProvider
        switch vpn.vpnStatus {
        case .connecting, .disconnecting:
            self.vpnIpValue.text = self.emptyIPValue
        default:
            break
        }
    }

    private func statusUpdated() {
    }
    
}
