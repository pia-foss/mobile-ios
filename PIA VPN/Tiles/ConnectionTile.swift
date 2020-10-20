//
//  ConnectionTile.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 16/07/2020.
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
import TunnelKit
import WidgetKit

class ConnectionTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet {
            statusUpdated()
        }
    }

    @IBOutlet private weak var tileTitle: UILabel!

    @IBOutlet private weak var protocolLabel: UILabel!
    @IBOutlet private weak var portLabel: UILabel!
    @IBOutlet private weak var authenticationLabel: UILabel!
    @IBOutlet private weak var encryptionLabel: UILabel!
    @IBOutlet private weak var socketLabel: UILabel!
    @IBOutlet private weak var handshakeLabel: UILabel!

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
        nc.addObserver(self, selector: #selector(setConnectionValues), name: .PIASettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(setConnectionValues), name: .PIAQuickSettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(setConnectionValues), name: .PIADaemonsDidUpdateVPNStatus, object: nil)

        setConnectionValues()
        viewShouldRestyle()
        self.tileTitle.text = L10n.Settings.Connection.title.uppercased()

    }
    
    @objc private func setConnectionValues() {
        
        if !Client.providers.vpnProvider.isVPNConnected {
            resetValues()
        }

        self.protocolLabel.text = Client.preferences.vpnType.vpnProtocol
        self.portLabel.text = Client.preferences.vpnType.port
        self.authenticationLabel.text = Client.preferences.vpnType.authentication
        self.encryptionLabel.text = Client.preferences.vpnType.encryption
        self.socketLabel.text = Client.preferences.vpnType.socket
        self.handshakeLabel.text = Client.preferences.vpnType.handshake
        
        self.protocolLabel.accessibilityLabel = Client.preferences.vpnType.vpnProtocol
        self.portLabel.accessibilityLabel = Client.preferences.vpnType.port
        self.authenticationLabel.accessibilityLabel = Client.preferences.vpnType.authentication
        self.encryptionLabel.accessibilityLabel = Client.preferences.vpnType.encryption
        self.socketLabel.accessibilityLabel = Client.preferences.vpnType.socket
        self.handshakeLabel.accessibilityLabel = Client.preferences.vpnType.handshake

    }
    
    private func resetValues() {
        self.protocolLabel.text = "---"
        self.portLabel.text = "---"
        self.authenticationLabel.text = "---"
        self.encryptionLabel.text = "---"
        self.socketLabel.text = "---"
        self.handshakeLabel.text = "---"
        
        self.protocolLabel.accessibilityLabel = L10n.Global.empty
        self.portLabel.accessibilityLabel = L10n.Global.empty
        self.authenticationLabel.accessibilityLabel = L10n.Global.empty
        self.encryptionLabel.accessibilityLabel = L10n.Global.empty
        self.socketLabel.accessibilityLabel = L10n.Global.empty
        self.handshakeLabel.accessibilityLabel = L10n.Global.empty
    }
    
    @objc private func viewShouldRestyle() {
        
        setConnectionValues()
        
        tileTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySettingsCellTitle(protocolLabel, appearance: .dark)
        Theme.current.applySettingsCellTitle(portLabel, appearance: .dark)
        Theme.current.applySettingsCellTitle(authenticationLabel, appearance: .dark)
        Theme.current.applySettingsCellTitle(encryptionLabel, appearance: .dark)
        Theme.current.applySettingsCellTitle(socketLabel, appearance: .dark)
        Theme.current.applySettingsCellTitle(handshakeLabel, appearance: .dark)
        Theme.current.applyPrincipalBackground(self)
    }
    
    private func statusUpdated() {
    }
    
}
