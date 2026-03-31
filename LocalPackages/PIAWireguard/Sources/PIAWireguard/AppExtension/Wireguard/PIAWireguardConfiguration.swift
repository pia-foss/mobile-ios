//
//  PIAWireguardConfiguration.swift
//  PIAWireguard
//  
//  Created by Jose Antonio Blaya Garcia on 25/02/2020.
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

public class PIAWireguardConfiguration: Codable {

    public struct Keys {
        public static let dnsServers = "customDNSServers"
        public static let packetSize = "packetSize"
        public static let token = "token"
        public static let serial = "serial"
        public static let ping = "ping"
        public static let useIP = "use_ip"
        public static let cn = "cn"
    }
    
    public private(set) var customDNSServers: [String]

    public private(set) var packetSize: Int

    public init(customDNSServers: [String], packetSize: Int) {
        self.customDNSServers = customDNSServers
        self.packetSize = packetSize
    }
    
}
