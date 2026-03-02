//
//  Server+Codable.swift
//  PIALibrary
//
//  Created by Mario on 02/03/2026.
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

import Foundation

extension Server: Codable {

    private enum CodingKeys: String, CodingKey {
        case serial
        case name
        case country
        case hostname = "dns"
        case geo
        case offline
        case latitude
        case longitude
        case regionIdentifier = "id"
        case isAutomatic = "auto_region"
        case pingAddress = "ping"
        case servers
        case dipToken
    }

    private struct ServerAddresses: Codable {
        let meta: [ServerAddressIP]?
        let ovpntcp: [ServerAddressIP]?
        let ovpnudp: [ServerAddressIP]?
        let wg: [ServerAddressIP]?
        let ikev2: [ServerAddressIP]?
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let country = try container.decode(String.self, forKey: .country)
        let hostname = try container.decode(String.self, forKey: .hostname)
        let serial = (try? container.decode(String.self, forKey: .serial)) ?? ""
        let geo = (try? container.decode(Bool.self, forKey: .geo)) ?? false
        let offline = (try? container.decode(Bool.self, forKey: .offline)) ?? false
        let latitude = try? container.decode(String.self, forKey: .latitude)
        let longitude = try? container.decode(String.self, forKey: .longitude)
        let regionIdentifier = try container.decode(String.self, forKey: .regionIdentifier)
        let dipToken = try? container.decode(String.self, forKey: .dipToken)
        let pingAddress = try? container.decode(Address.self, forKey: .pingAddress)
        let isAutomatic = (try? container.decode(Bool.self, forKey: .isAutomatic)) ?? false

        var meta: ServerAddressIP?
        var ovpnTCP: [ServerAddressIP]?
        var ovpnUDP: [ServerAddressIP]?
        var wg: [ServerAddressIP]?
        var ikev2: [ServerAddressIP]?

        if let serverAddresses = try? container.decode(ServerAddresses.self, forKey: .servers) {
            meta = serverAddresses.meta?.last
            ovpnTCP = serverAddresses.ovpntcp
            ovpnUDP = serverAddresses.ovpnudp
            wg = serverAddresses.wg
            ikev2 = serverAddresses.ikev2
        }

        self.init(
            serial: serial,
            name: name,
            country: country,
            hostname: hostname,
            openVPNAddressesForTCP: ovpnTCP,
            openVPNAddressesForUDP: ovpnUDP,
            wireGuardAddressesForUDP: wg,
            iKEv2AddressesForUDP: ikev2,
            pingAddress: pingAddress,
            geo: geo,
            offline: offline,
            latitude: latitude,
            longitude: longitude,
            meta: meta,
            dipToken: dipToken,
            regionIdentifier: regionIdentifier,
            isAutomatic: isAutomatic
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(serial, forKey: .serial)
        try container.encode(name, forKey: .name)
        try container.encode(country, forKey: .country)
        try container.encode(hostname, forKey: .hostname)
        try container.encode(geo, forKey: .geo)
        try container.encode(offline, forKey: .offline)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encode(regionIdentifier, forKey: .regionIdentifier)
        try container.encode(isAutomatic, forKey: .isAutomatic)
        try container.encodeIfPresent(pingAddress?.description, forKey: .pingAddress)
        try container.encodeIfPresent(dipToken, forKey: .dipToken)
        var metaArray: [ServerAddressIP]?
        if let meta {
            metaArray = [meta]
        }
        let serverAddresses = ServerAddresses(
            meta: metaArray,
            ovpntcp: openVPNAddressesForTCP,
            ovpnudp: openVPNAddressesForUDP,
            wg: wireGuardAddressesForUDP,
            ikev2: iKEv2AddressesForUDP,
        )
        try container.encode(serverAddresses, forKey: .servers)
    }
}

// MARK: - Server.ServerAddressIP: Decodable

extension Server.ServerAddressIP: Decodable {
    enum CodingKeys: CodingKey {
        case ip, cn, van, responseTime, available
    }

    public convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            ip: try container.decode(String.self, forKey: .ip),
            cn: try container.decode(String.self, forKey: .cn),
            van: (try? container.decode(Bool.self, forKey: .van)) ?? false,
        )
    }
}

// MARK: - Server.Address Codable

extension Server.Address: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string: string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
