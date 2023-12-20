//
//  VpnConfigurationProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/12/23.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol VpnConfigurationProviderType {
    func install(force forceInstall: Bool, _ callback: SuccessLibraryCallback?)
}

class VpnConfigurationProvider: VpnConfigurationProviderType {
    private let vpnProvider: VPNProvider
    
    init(vpnProvider: VPNProvider) {
        self.vpnProvider = vpnProvider
    }
    
    func install(force forceInstall: Bool, _ callback: PIALibrary.SuccessLibraryCallback?) {
        vpnProvider.install(force: forceInstall, callback)
    }
}
