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
        return VpnConnectionUseCase(serverProvider: makeServerProvider(), vpnProvider: makeVpnProvider())
    }()
    
    static func makeServerProvider() -> ServerProviderType {
        guard let defaultServerProvider: DefaultServerProvider =
                Client.providers.serverProvider as? DefaultServerProvider else {
            fatalError("Incorrect server provider type")
        }
        
        return defaultServerProvider
        
    }
    
    static func makeVpnProvider() -> VPNStatusProviderType {
        guard let defaultVpnProvider =  Client.providers.vpnProvider as? DefaultVPNProvider else {
            fatalError("Incorrect VPNProvider type")
        }
        
        return defaultVpnProvider
        
    }
}
