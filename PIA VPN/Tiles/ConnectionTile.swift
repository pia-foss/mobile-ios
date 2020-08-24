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
    }
    
    private func resetValues() {
        self.protocolLabel.text = "---"
        self.portLabel.text = "---"
        self.authenticationLabel.text = "---"
        self.encryptionLabel.text = "---"
        self.socketLabel.text = "---"
        self.handshakeLabel.text = "---"
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

private extension String {
    
    var vpnProtocol: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "WireGuard®"
        case PIATunnelProfile.vpnType:
            return "OpenVPN"
        case IKEv2Profile.vpnType:
            return "IPSec (IKEv2)"
        default:
            return self
        }
    }
    
    var port: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "1337"
        case PIATunnelProfile.vpnType:
            if AppPreferences.shared.piaSocketType != nil {
                let preferences = Client.preferences.editable()
                if let currentOpenVPNConfiguration = preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNTunnelProvider.Configuration {
                    let port = currentOpenVPNConfiguration.sessionConfiguration.builder().endpointProtocols?.first?.port ?? 0
                    return "\(port)"
                }
            } else {
                return L10n.Global.automatic
            }
            return "---"
        case IKEv2Profile.vpnType:
            return "500"
        default:
            return "---"
        }
    }
    
    var socket: String {
        switch self {
        case PIAWGTunnelProfile.vpnType, IKEv2Profile.vpnType:
            return "UDP"
        case PIATunnelProfile.vpnType:
            return AppPreferences.shared.piaSocketType?.rawValue ?? L10n.Global.automatic
        default:
            return self

        }
    }
    
    var handshake: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "Noise_IK"
        case PIATunnelProfile.vpnType:
            return AppPreferences.shared.piaHandshake.description
        case IKEv2Profile.vpnType:
            let preferences = Client.preferences.editable()
            return preferences.ikeV2IntegrityAlgorithm
        default:
            return self
        }
    }

    var encryption: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "ChaCha20"
        case PIATunnelProfile.vpnType:
            let preferences = Client.preferences.editable()
            if let currentOpenVPNConfiguration = preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNTunnelProvider.Configuration {
                return currentOpenVPNConfiguration.sessionConfiguration.builder().cipher?.rawValue ?? ""
            }
            return "---"
        case IKEv2Profile.vpnType:
            let preferences = Client.preferences.editable()
            return preferences.ikeV2EncryptionAlgorithm
        default:
            return self
        }
    }
    
    var authentication: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "Poly1305"
        case PIATunnelProfile.vpnType:
            let preferences = Client.preferences.editable()
            if let currentOpenVPNConfiguration = preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNTunnelProvider.Configuration {
                return currentOpenVPNConfiguration.sessionConfiguration.builder().digest?.rawValue ?? ""
            }
            return "---"
        case IKEv2Profile.vpnType:
            return "---"
        default:
            return self
        }
    }
    
}
