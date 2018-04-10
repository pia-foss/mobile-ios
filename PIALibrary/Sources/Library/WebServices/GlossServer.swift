//
//  Server+Gloss.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/10/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
            name: name,
            country: country,
            hostname: hostname,
            bestOpenVPNAddressForTCP: ovpnTCPAddress,
            bestOpenVPNAddressForUDP: ovpnUDPAddress,
            pingAddress: pingAddress
        )
    }
}

/// :nodoc:
extension Server: JSONEncodable {
    public func toJSON() -> JSON? {
        return jsonify([
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
