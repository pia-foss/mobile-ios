//
//  AppConstants+CustomServers.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 13.01.26.
//  Copyright © 2026 Private Internet Access, Inc.
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

import PIALibrary
import Foundation

extension AppConstants {
    struct Servers {
        static var customServers: [Server]? = {
            guard let path = Bundle.main.path(forResource: "custom", ofType: "servers") else {
                return nil
            }
            guard let content = try? String(contentsOfFile: path) else {
                return nil
            }

            var servers: [Server] = []
            let lines = content.components(separatedBy: "\n")
            for line in lines {
                let tokens = line.components(separatedBy: ":")
                guard tokens.count == 6 else {
                    continue
                }

                let name = tokens[0]
                let country = tokens[1]
                let hostname = tokens[2]
                let address = tokens[3]

                guard let udpPort = UInt16(tokens[4]) else {
                    continue
                }
                guard let tcpPort = UInt16(tokens[5]) else {
                    continue
                }

                servers.append(Server(
                    serial: "",
                    name: name,
                    country: country,
                    hostname: hostname,
                    pingAddress: nil,
                    regionIdentifier: ""
                ))
            }
            return servers
        }()
    }
}
