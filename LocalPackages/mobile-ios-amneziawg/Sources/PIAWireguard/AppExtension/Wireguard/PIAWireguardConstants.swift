//
//  PIAWireguardConstants.swift
//  PIAWireguard
//  
//  Created by Jose Antonio Blaya Garcia on 26/02/2020.
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

struct PIAWireguardConstants {

    static let allowedIPRange = "0.0.0.0/0"

    static let persistentKeepaliveInterval = "25"

    static let tunnelRemoteAddress = "127.0.0.1"
    
    static let mtu = 1280
    
    static let remotePort = 1337
    
    struct API {
        
        static let addKeyEndpoint = "addKey"
        
        static let publicKeyParameter = "pubkey"

        static let authTokenParameter = "pt"
        
    }
}
