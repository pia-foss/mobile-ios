//
//  PowerTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class PowerTile: UIView, Tileable  {
    
    var detailViewAction: Func!
    var view: UIView!
    var detailSegueIdentifier: String!

    @IBOutlet private weak var toggleConnection: PIAConnectionButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }

    private func setupView() {
        self.detailViewAction = {}
        let currentStatus = Client.providers.vpnProvider.vpnStatus
        
        //Theme.current.applyVPNStatus(labelStatus, forStatus: currentStatus)
        
        switch currentStatus {
        case .connected:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = false
            toggleConnection.stopButtonAnimation()
        case .disconnected:
            toggleConnection.isOn = false
            toggleConnection.isIndeterminate = false
            toggleConnection.stopButtonAnimation()
        case .connecting:
            toggleConnection.isOn = false
            toggleConnection.isIndeterminate = true
            toggleConnection.startButtonAnimation()
        case .disconnecting:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = true
            toggleConnection.startButtonAnimation()
        }

    }

    @IBAction func vpnButtonClicked(_ sender: Any?) {
        if !toggleConnection.isOn {
            Client.providers.vpnProvider.connect(nil)
        } else {
            Client.providers.vpnProvider.disconnect(nil)
        }
    }
    
}
