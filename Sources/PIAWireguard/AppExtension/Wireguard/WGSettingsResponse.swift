//
//  WGSettingsResponse.swift
//  PIAWireguard
//  
//  Created by Jose Antonio Blaya Garcia on 13/02/2020.
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

class WGSettingsResponse {
    
    var settingsDictionary: [String: String] = [:]
    
    var listen_port: String {
        return settingsDictionary["listen_port"] ?? ""
    }
    var public_key: String {
        return settingsDictionary["public_key"] ?? ""
    }
    var preshared_key: String {
        return settingsDictionary["preshared_key"] ?? ""
    }
    var protocol_version: String {
        return settingsDictionary["protocol_version"] ?? ""
    }
    var endpoint: String {
        return settingsDictionary["endpoint"] ?? ""
    }
    var last_handshake_time_sec: Date {
        let handshakeTime = settingsDictionary["last_handshake_time_sec"] ?? ""
        if handshakeTime != "", handshakeTime != "0", let time = Double(handshakeTime), time != 0.0 {
            return Date(timeIntervalSince1970: time)
        } else {
            return Date()
        }
    }
    var last_handshake_time_nsec: String {
        return settingsDictionary["last_handshake_time_nsec"] ?? ""
    }
    var tx_bytes: UInt64 {
        return UInt64(settingsDictionary["tx_bytes"] ?? "0") ?? 0
    }
    var rx_bytes: UInt64 {
        return UInt64(settingsDictionary["rx_bytes"] ?? "0") ?? 0
    }
    var persistent_keepalive_interval: Double {
        let keepaliveInterval = settingsDictionary["persistent_keepalive_interval"] ?? ""
        if let time = Double(keepaliveInterval) {
            return time
        } else {
            return 0.0
        }

    }
    var allowed_ip: String {
        return settingsDictionary["allowed_ip"] ?? ""
    }


    init(withSettings settings: String) {
        
        let components = settings.components(separatedBy: "\n")

        for component in components{
            let pair = component.components(separatedBy: "=")
            if pair.count == 2 {
                settingsDictionary[pair[0]] = pair[1]
            }
        }

    }
    
}

extension WGSettingsResponse {
    
    func isHandshakeCompleted() -> Bool {
    
        let lastHandshake = self.last_handshake_time_sec
        //2 minutes without handshake
        let nextHandshake = lastHandshake.addingTimeInterval(150)
        
        wg_log(.info, message: "Last handshake \(lastHandshake)")
        
        //the last handshake was more than 2 minutes ago
        if nextHandshake > Date() {
            return true
        }
                
        return false
        
    }
    
}
