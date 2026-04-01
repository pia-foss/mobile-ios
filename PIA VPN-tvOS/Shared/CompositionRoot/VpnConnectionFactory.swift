//
//  VpnConnectionFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class VpnConnectionFactory {
    static var makeVpnConnectionUseCase: VpnConnectionUseCaseType = {
        return VpnConnectionUseCase(serverProvider: makeServerProvider(), vpnProvider: makeVpnProvider, vpnStatusMonitor: StateMonitorsFactory.makeVPNStatusMonitor, clientPreferences: RegionsSelectionFactory.makeClientPreferences)
    }()
    
    static func makeServerProvider() -> ServerProviderType {
        guard let defaultServerProvider: DefaultServerProvider =
                Client.providers.serverProvider as? DefaultServerProvider else {
            fatalError("Incorrect server provider type")
        }
        
        return defaultServerProvider
        
    }
    
    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    static var makeVpnProvider: VPNStatusProviderType = {
        if isSimulator {
            return MockVPNProvider()
        } else {
            guard let vpnProvider =  Client.providers.vpnProvider as? VPNStatusProviderType else {
                fatalError("Incorrect VPNProvider type")
            }
            
            return vpnProvider
        }
        
    }()
}
