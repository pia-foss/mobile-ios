//
//  StateMonitorsFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class StateMonitorsFactory {
    static var makeUserAuthenticationStatusMonitor: UserAuthenticationStatusMonitorType = {
        UserAuthenticationStatusMonitor(currentStatus: Client.providers.accountProvider.isLoggedIn ? .loggedIn : .loggedOut,
                                        notificationCenter: NotificationCenter.default)
    }()
    
    static var makeVPNStatusMonitor: VPNStatusMonitorType = {
        guard let defaultVPNProvider = Client.providers.vpnProvider as? DefaultVPNProvider else {
            fatalError("Incorrect vpn provider type")
        }
        
        return VPNStatusMonitor(vpnStatusProvider: defaultVPNProvider,
                                notificationCenter: NotificationCenter.default)
    }()
    
    static var makeConnectionStateMonitor: ConnectionStateMonitorType = {
        return ConnectionStateMonitor(vpnStatusMonitor: makeVPNStatusMonitor, vpnConnectionUseCase: VpnConnectionFactory.makeVpnConnectionUseCase)
    }()
    
}

