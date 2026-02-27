//
//  IPTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
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
import PIADesignSystem
import PIAUIKit
import Combine

class IPTile: UIView, Tileable  {
    
    private let emptyIPValue = "---"
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal

    private var cancellables = Set<AnyCancellable>()

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
        cancellables.removeAll()
    }
    
    private func setupView() {
        
        let nc = NotificationCenter.default
        nc.publisher(for: .PIAThemeDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewShouldRestyle()
            }
            .store(in: &cancellables)

        Client.daemons.ipsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ips in
                self?.updateIPLabels(
                    publicIP: ips.publicIP,
                    vpnIP: ips.vpnIP
                )
            }
            .store(in: &cancellables)

        viewShouldRestyle()
        self.accessibilityIdentifier = "IPTile"
        self.localIpTitle.text = "IP"
        self.vpnIpTitle.text = "VPN IP"
        self.localIpValue.text = Client.daemons.publicIP ?? emptyIPValue
        self.localIpValue.accessibilityLabel = Client.daemons.publicIP ?? L10n.Localizable.Global.empty
        self.vpnIpValue.text = emptyIPValue
        self.vpnIpValue.accessibilityLabel = L10n.Localizable.Global.empty

    }
    
    private func viewShouldRestyle() {
        localIpTitle.style(style: TextStyle.textStyle21)
        vpnIpTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySettingsCellTitle(localIpValue, appearance: .dark)
        Theme.current.applySettingsCellTitle(vpnIpValue, appearance: .dark)
        Theme.current.applyPrincipalBackground(self)
    }
    
    private func updateIPLabels(publicIP: String?, vpnIP: String?) {
        self.localIpValue.text = publicIP ?? emptyIPValue
        self.localIpValue.accessibilityLabel = publicIP ?? L10n.Localizable.Global.empty
        self.vpnIpValue.text = vpnIP ?? self.emptyIPValue
        self.vpnIpValue.accessibilityLabel = vpnIP ?? L10n.Localizable.Global.empty
    }
}
