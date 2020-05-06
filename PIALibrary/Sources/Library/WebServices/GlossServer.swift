//
//  Server+Gloss.swift
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

class GlossServer: GlossParser {
    
    let parsed: Server

    required init?(json: JSON) {
        
        guard let name: String = "name" <~~ json else {
            return nil
        }
        guard let country: String = "country" <~~ json else {
            return nil
        }
        guard let hostname: String = "dns" <~~ json else {
            return nil
        }

        if Client.configuration.serverNetwork == .gen4 {
            
            var ovpnTCPServerAddressIP: [Server.ServerAddressIP] = []
            if let ovpnTCP: [String: Any] = "servers" <~~ json {
                if let addressArray: [JSON] = "ovpntcp" <~~ ovpnTCP {
                    for address in addressArray {
                        if let ip: String = "ip" <~~ address,
                            let cn: String = "cn" <~~ address {
                            ovpnTCPServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn))
                        }
                    }
                }
            }
            
            var ovpnUDPServerAddressIP: [Server.ServerAddressIP] = []
            if let ovpnUDP: [String: Any] = "servers" <~~ json {
                if let addressArray: [JSON] = "ovpnudp" <~~ ovpnUDP {
                    for address in addressArray {
                        if let ip: String = "ip" <~~ address,
                            let cn: String = "cn" <~~ address {
                            ovpnUDPServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn))
                        }
                    }
                }
            }
            
            var wgServerAddressIP: [Server.ServerAddressIP] = []
            if let wgUDP: [String: Any] = "servers" <~~ json {
                if let addressArray: [JSON] = "wg" <~~ wgUDP {
                    for address in addressArray {
                        if let ip: String = "ip" <~~ address,
                            let cn: String = "cn" <~~ address {
                            wgServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn))
                        }
                    }
                }
            }
            
            var ikev2ServerAddressIP: [Server.ServerAddressIP] = []
            if let ikev2UDP: [String: Any] = "servers" <~~ json {
                if let addressArray: [JSON] = "ikev2" <~~ ikev2UDP {
                    for address in addressArray {
                        if let ip: String = "ip" <~~ address,
                            let cn: String = "cn" <~~ address {
                            ikev2ServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn))
                        }
                    }
                }
            }

            var pingAddress: Server.Address?
            if let pingString: String = "ping" <~~ json {
                pingAddress = try? Server.Address(string: pingString)
            }

            parsed = Server(serial: "",
                            name: name,
                            country: country,
                            hostname: hostname,
                            bestOpenVPNAddressForTCP: nil,
                            bestOpenVPNAddressForUDP: nil,
                            openVPNAddressesForTCP: ovpnTCPServerAddressIP,
                            openVPNAddressesForUDP: ovpnUDPServerAddressIP,
                            wireGuardAddressesForUDP: wgServerAddressIP,
                            iKEv2AddressesForUDP: ikev2ServerAddressIP,
                            pingAddress: pingAddress,
                            responseTime: 0,
                            serverNetwork: .gen4)
            
            if let autoRegion: Bool = "auto_region" <~~ json {
                parsed.isAutomatic = autoRegion
            }
            
        } else {
            
            var serial = ""
            if let serialValue: String = "serial" <~~ json {
                serial = serialValue
            }
            
            var ovpnTCPAddress: Server.Address?
            if let ovpnTCP: [String: Any] = "openvpn_tcp" <~~ json {
                if let addressString: String = "best" <~~ ovpnTCP {
                    ovpnTCPAddress = try? Server.Address(string: addressString)
                }
            }
            var ovpnUDPAddress: Server.Address?
            if let ovpnUDP: [String: Any] = "openvpn_udp" <~~ json {
                if let addressString: String = "best" <~~ ovpnUDP {
                    ovpnUDPAddress = try? Server.Address(string: addressString)
                }
            }
            
            var pingAddress: Server.Address?
            if let pingString: String = "ping" <~~ json {
                pingAddress = try? Server.Address(string: pingString)
            }

            parsed = Server(
                serial: serial,
                name: name,
                country: country,
                hostname: hostname,
                bestOpenVPNAddressForTCP: ovpnTCPAddress,
                bestOpenVPNAddressForUDP: ovpnUDPAddress,
                pingAddress: pingAddress
            )
            
        }

    }
    
}

/// :nodoc:
extension Server: JSONEncodable {
    public func toJSON() -> JSON? {
        return jsonify([
            "serial" ~~> serial,
            "name" ~~> name,
            "country" ~~> country,
            "dns" ~~> hostname,
            "openvpn_tcp" ~~> jsonify([
                "best" ~~> bestOpenVPNAddressForTCP?.description
            ]),
            "openvpn_udp" ~~> jsonify([
                "best" ~~> bestOpenVPNAddressForUDP?.description
            ]),
            "ping" ~~> pingAddress?.description
        ])
    }
}
