//
//  ServerTile+App.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 05/04/2019.
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

import Foundation
import PIALibrary

public extension Tileable {
    
    /**
     Connect to the server given as paramenter
     - Parameter server: The server to connect.
     */
    func connectTo(server: Server) {
        
        //User clicked the button, the selection of the region to connect the VPN was manual
        Client.configuration.connectedManually = true

        let isConnected = Client.providers.vpnProvider.isVPNConnected
        let currentServer = Client.preferences.displayedServer
        if isConnected {
            guard (server.identifier != currentServer.identifier || server.dipToken != currentServer.dipToken) else {
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

