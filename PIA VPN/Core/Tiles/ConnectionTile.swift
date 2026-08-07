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

import PIAAssetsMobile
import PIADesignSystem
import PIALibrary
import PIALocalizations
import PIAUIKit
import TunnelKitCore
import TunnelKitOpenVPN
import UIKit
import WidgetKit

class ConnectionTile: UIView, Tileable {

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

    @IBOutlet private weak var protocolIcon: UIImageView!
    @IBOutlet private weak var portIcon: UIImageView!
    @IBOutlet private weak var authenticationIcon: UIImageView!
    @IBOutlet private weak var encryptionIcon: UIImageView!
    @IBOutlet private weak var socketIcon: UIImageView!
    @IBOutlet private weak var handshakeIcon: UIImageView!

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

        // Through the PlatformSDK tunnel the extension writes the actual connection (protocol/server/
        // transport) into shared state after connecting, out of band with VPN status changes. Observe
        // those cross-process writes so the tile reflects the resolved values promptly.
        if Client.configuration.featureFlags[.usePlatformSDKVPN] {
            PIATunnelSharedState.startObserving()
            nc.addObserver(
                self, selector: #selector(setConnectionValues),
                name: PIATunnelSharedState.didChangeNotification, object: nil)
        }

        protocolIcon.image = Asset.Piax.Tiles.ConnectionTile.iconProtocol.image
        portIcon.image = Asset.Piax.Tiles.ConnectionTile.iconPort.image
        authenticationIcon.image = Asset.Piax.Tiles.ConnectionTile.iconAuthentication.image
        encryptionIcon.image = Asset.Piax.Tiles.ConnectionTile.iconEncryption.image
        socketIcon.image = Asset.Piax.Tiles.ConnectionTile.iconSocket.image
        handshakeIcon.image = Asset.Piax.Tiles.ConnectionTile.iconHandshake.image

        setConnectionValues()
        viewShouldRestyle()
        self.tileTitle.text = L10n.Settings.Connection.title.uppercased()

    }

    @objc private func setConnectionValues() {

        if !Client.providers.vpnProvider.isVPNConnected {
            resetValues()
        }

        // When connected through the PlatformSDK tunnel, show what the tunnel actually resolved (e.g.
        // WireGuard under "Automatic", or the concrete UDP/TCP for an OpenVPN "Automatic" transport)
        // rather than the user's selection; otherwise fall back to the selected values.
        let connection = Client.providers.vpnProvider.actualConnection
        let displayVPNType = connection?.vpnType?.rawValue ?? Client.preferences.vpnType
        let displaySocket = connection?.transport.rawValue.uppercased() ?? displayVPNType.socket

        self.protocolLabel.text = displayVPNType.vpnProtocol
        self.portLabel.text = displayVPNType.port
        self.authenticationLabel.text = displayVPNType.authentication
        self.encryptionLabel.text = displayVPNType.encryption
        self.socketLabel.text = displaySocket
        self.handshakeLabel.text = displayVPNType.handshake

        self.protocolLabel.accessibilityLabel = displayVPNType.vpnProtocol
        self.portLabel.accessibilityLabel = displayVPNType.port
        self.authenticationLabel.accessibilityLabel = displayVPNType.authentication
        self.encryptionLabel.accessibilityLabel = displayVPNType.encryption
        self.socketLabel.accessibilityLabel = displaySocket
        self.handshakeLabel.accessibilityLabel = displayVPNType.handshake

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
