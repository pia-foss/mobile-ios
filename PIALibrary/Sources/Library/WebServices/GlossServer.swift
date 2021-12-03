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
        
        let dipToken: String? = "dipToken" <~~ json ?? nil

        let geo: Bool = "geo" <~~ json ?? false
        let offline: Bool = "offline" <~~ json ?? false
        let latitude: String? = "latitude" <~~ json ?? nil
        let longitude: String? = "longitude" <~~ json ?? nil

        var meta: Server.ServerAddressIP?
        if let metaServer: [String: Any] = "servers" <~~ json {
            if let addressArray: [JSON] = "meta" <~~ metaServer {
                for address in addressArray {
                    if let ip: String = "ip" <~~ address,
                        let cn: String = "cn" <~~ address {
                        meta = Server.ServerAddressIP(ip: ip, cn: cn, van: false)
                    }
                }
            }
        }

        guard let regionIdentifier: String = "id" <~~ json else {
           return nil
        }
        
        var ovpnTCPServerAddressIP: [Server.ServerAddressIP] = []
        if let ovpnTCP: [String: Any] = "servers" <~~ json {
            if let addressArray: [JSON] = "ovpntcp" <~~ ovpnTCP {
                for address in addressArray {
                    if let ip: String = "ip" <~~ address,
                        let cn: String = "cn" <~~ address {
                        let van: Bool = "van" <~~ address ?? false
                        ovpnTCPServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn, van: van))
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
                        let van: Bool = "van" <~~ address ?? false
                        ovpnUDPServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn, van: van))
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
                        wgServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn, van: false))
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
                        ikev2ServerAddressIP.append(Server.ServerAddressIP(ip: ip, cn: cn, van: false))
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
                        openVPNAddressesForTCP: ovpnTCPServerAddressIP,
                        openVPNAddressesForUDP: ovpnUDPServerAddressIP,
                        wireGuardAddressesForUDP: wgServerAddressIP,
                        iKEv2AddressesForUDP: ikev2ServerAddressIP,
                        pingAddress: pingAddress,
                        responseTime: 0,
                        geo: geo,
                        offline: offline,
                        latitude: latitude,
                        longitude: longitude,
                        meta: meta,
                        dipToken: dipToken,
                        regionIdentifier: regionIdentifier
        )
        
        if let autoRegion: Bool = "auto_region" <~~ json {
            parsed.isAutomatic = autoRegion
        }

    }
    
}

/// :nodoc:
extension Server: JSONEncodable {
    public func toJSON() -> JSON? {
        
        //Add meta into array if not null
        var metaArray:[Server.ServerAddressIP]? = []
        
        if let meta = meta {
            metaArray?.append(meta)
        }
        
        //Retrieve values for each protocol
        let ovpnTCP = try? JSONEncoder().encode(openVPNAddressesForTCP)
        let ovpnUDP = try? JSONEncoder().encode(openVPNAddressesForUDP)
        let wgUDP = try? JSONEncoder().encode(wireGuardAddressesForUDP)
        let ikeV2UDP = try? JSONEncoder().encode(iKEv2AddressesForUDP)
        let metaArrayData = try? JSONEncoder().encode(metaArray)



        let ovpnTCPobj = try? JSONSerialization.jsonObject(with: ovpnTCP ?? Data(), options: .mutableContainers)
        let ovpnUDPobj = try? JSONSerialization.jsonObject(with: ovpnUDP ?? Data(), options: .mutableContainers)
        let wgUDPobj = try? JSONSerialization.jsonObject(with: wgUDP ?? Data(), options: .mutableContainers)
        let ikeV2UDPobj = try? JSONSerialization.jsonObject(with: ikeV2UDP ?? Data(), options: .mutableContainers)
        let metaObj = try? JSONSerialization.jsonObject(with: metaArrayData ?? Data(), options: .mutableContainers)

        var jsonified = jsonify([
            "serial" ~~> serial,
            "name" ~~> name,
            "country" ~~> country,
            "geo" ~~> geo,
            "offline" ~~> offline,
            "dns" ~~> hostname,
            "ping" ~~> pingAddress?.description,
            "servers" ~~> jsonify([
                "meta" ~~> metaObj,
                "ovpnudp" ~~> ovpnUDPobj,
                "ovpntcp" ~~> ovpnTCPobj,
                "wg" ~~> wgUDPobj,
                "ikev2" ~~> ikeV2UDPobj,
            ]),
            "dipToken" ~~> dipToken,
            "id" ~~> regionIdentifier
        ])

        
        return jsonified
    }
}
