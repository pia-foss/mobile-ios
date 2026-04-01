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
        return VPNStatusMonitor(vpnStatusProvider: VpnConnectionFactory.makeVpnProvider,
                                notificationCenter: NotificationCenter.default)
    }()
    
    static var makeConnectionStateMonitor: ConnectionStateMonitorType = {
        return ConnectionStateMonitor(vpnStatusMonitor: makeVPNStatusMonitor, vpnConnectionUseCase: VpnConnectionFactory.makeVpnConnectionUseCase)
    }()
    
}

