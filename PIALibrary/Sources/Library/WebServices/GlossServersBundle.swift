//
//  ServersBundle+Gloss.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/10/17.
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
import Gloss

class ServersResponse {
    private let originalLength: Int

    private let jsonString: String
    
    private let signature: Data

    init?(data: Data) {
        guard let dirtyString = String(data: data, encoding: .utf8) else {
            return nil
        }
        let dirtyLines = dirtyString.components(separatedBy: "\n\n")
        guard let jsonString = dirtyLines.first, let signatureString = dirtyLines.last else {
            return nil
        }
        guard let signature = Data(base64Encoded: signatureString, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        originalLength = data.count
        self.jsonString = jsonString
        self.signature = signature
    }

    func writeBundle(to file: String) throws {
        try jsonString.write(toFile: file, atomically: true, encoding: .utf8)
    }

    func bundle() -> ServersBundle? {
        return GlossServersBundle(jsonString: jsonString)?.parsed
    }
    
}

class GlossServersBundle: GlossParser {
    
    class Configuration: GlossParser {
        class Ports: GlossParser {
            let parsed: ServersBundle.Configuration.Ports

            required init?(json: JSON) {
                guard let udp: [UInt16] = "udp" <~~ json else {
                    return nil
                }
                guard let tcp: [UInt16] = "tcp" <~~ json else {
                    return nil
                }
                
                parsed = ServersBundle.Configuration.Ports(
                    udp: udp,
                    tcp: tcp
                )
            }
        }
            
        let parsed: ServersBundle.Configuration
        
        required init?(json: JSON) {
            guard let vpnPorts: Ports = "vpn_ports" <~~ json else {
                return nil
            }
            guard let latestVersion: Int = "latest_version" <~~ json else {
                return nil
            }
            guard let pollIntervalSeconds: Int = "poll_interval" <~~ json else {
                return nil
            }
            var automaticIdentifiers: Set<String>?
            if let automaticIdentifiersArray: [String] = "auto_regions" <~~ json {
                automaticIdentifiers = Set(automaticIdentifiersArray)
            }

            parsed = ServersBundle.Configuration(
                ovpnPorts: vpnPorts.parsed,
                wgPorts: vpnPorts.parsed,
                ikev2Ports: vpnPorts.parsed,
                latestVersion: latestVersion,
                pollInterval: pollIntervalSeconds * 1000,
                automaticIdentifiers: automaticIdentifiers
            )
        }
    }
    
    var parsed: ServersBundle
    
    convenience init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        self.init(jsonData: data)
    }

    convenience init?(jsonFile: String) {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: jsonFile)) else {
            return nil
        }
        self.init(jsonData: data)
    }
    
    convenience init?(jsonData: Data) {
        guard let anyJSON = try? JSONSerialization.jsonObject(with: jsonData, options: []), let json = anyJSON as? JSON else {
            return nil
        }
        self.init(json: json)
    }

    // MARK: Decodable

    public required init?(json: JSON) {
        
        // Init configuration object
        parsed = ServersBundle(servers: [], configuration: nil)
        parseGEN4Data(json)

    }
    
    private func parseGEN4Data(_ json: JSON) {
        //groups and regions
                
        var servers: [Server] = []
        
        // Check regions
        if let regionList = json["regions"] as? [JSON] {

            for region in regionList {
                guard let serverJSON = region as? JSON else {
                    continue
                }
                guard let _ = serverJSON["country"] as? String else {
                    continue
                }
                guard let server = GlossServer(json: serverJSON)?.parsed else {
                    continue
                }
                servers.append(server)
            }
            servers.sort { $0.name < $1.name }

        }

        let configuration = parseGEN4Configuration(json)
        
        parsed = ServersBundle(
            servers: servers,
            configuration: configuration
        )

    }
    
    private func parseGEN4Configuration(_ json: JSON) -> ServersBundle.Configuration {
        
        var ovpnTCPPorts: [UInt16] = []
        var ovpnUDPPorts: [UInt16] = []
        var wgPorts: [UInt16] = []
        var ikeV2Ports: [UInt16] = []
        var ovpnTCPLatencyPort: UInt16?
        var ovpnUDPLatencyPort: UInt16?
        var wgLatencyPort: UInt16?
        var ikeV2LatencyPort: UInt16?

        if let groupList = json["groups"] as? JSON {
            
            if let ovpntcpArray = groupList["ovpntcp"] as? [JSON] {
                for ovpntcp in ovpntcpArray {
                    if let name = ovpntcp["name"] as? String {
                        if name == "openvpn_tcp" {
                            if let ports = ovpntcp["ports"] as? [UInt16] {
                                ovpnTCPPorts = ports
                            }
                        }
                    }
                }
            }
            
            if let ovpnudpArray = groupList["ovpnudp"] as? [JSON] {
                for ovpnudp in ovpnudpArray {
                    if let name = ovpnudp["name"] as? String {
                        if name == "openvpn_udp" {
                            if let ports = ovpnudp["ports"] as? [UInt16] {
                                ovpnUDPPorts = ports
                            }
                        }
                    }
                }
            }

            if let wgArray = groupList["wg"] as? [JSON] {
                for wg in wgArray {
                    if let name = wg["name"] as? String {
                        if name == "wg" {
                            if let ports = wg["ports"] as? [UInt16] {
                                wgPorts = ports
                            }
                        }
                    }
                }
            }

            if let ikev2Array = groupList["ikev2"] as? [JSON] {
                for ikev2 in ikev2Array {
                    if let name = ikev2["name"] as? String {
                        if name == "ikev2" {
                            if let ports = ikev2["ports"] as? [UInt16] {
                                ikeV2Ports = ports
                            }
                        }
                    }
                }

            }

        }
        
        return ServersBundle.Configuration(ovpnPorts: ServersBundle.Configuration.Ports(udp: ovpnUDPPorts, tcp: ovpnTCPPorts),
                                           wgPorts: ServersBundle.Configuration.Ports(udp: wgPorts, tcp: []),
                                           ikev2Ports: ServersBundle.Configuration.Ports(udp: ikeV2Ports, tcp: []),
                                           latestVersion: 102,
                                           pollInterval: 600000,
                                           automaticIdentifiers: nil)
        
    }
    
}
