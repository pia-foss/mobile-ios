//
//  WGPacketTunnelProvider+IP.swift
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

import NetworkExtension
import os.log
import __PIAWireGuardNative

extension WGPacketTunnelProvider {

       
    /**
        Translates a hostname into an ip.
        - Parameter hostname: The hostname to resolve.
        - Returns: The IP string.
    */
    func hostnameToIP(_ hostname: String) -> String? {
        
        guard let host = hostname.withCString({gethostbyname($0)}) else {
            return nil
        }

        guard host.pointee.h_length > 0 else {
            return nil
        }

        var addr = in_addr()
        memcpy(&addr.s_addr, host.pointee.h_addr_list[0], Int(host.pointee.h_length))

        guard let remoteIPAsC = inet_ntoa(addr) else {
            return nil
        }

        return String.init(cString: remoteIPAsC)
    }
}



