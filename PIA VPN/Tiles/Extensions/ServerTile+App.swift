//
//  ServerTile+App.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 05/04/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

public extension Tileable {
    
    /**
     Connect to the server given as paramenter
     - Parameter server: The server to connect.
     */
    func connectTo(server: Server) {
        let isConnected = Client.providers.vpnProvider.isVPNConnected
        let currentServer = Client.preferences.displayedServer
        if isConnected {
            guard (server.identifier != currentServer.identifier) else {
                return
            }
        }
        Client.preferences.displayedServer = server
        NotificationCenter.default.post(name: .PIAThemeDidChange,
                                        object: self,
                                        userInfo: nil)
        if !isConnected {
            Client.providers.vpnProvider.connect(nil)
        }
    }
    
}

