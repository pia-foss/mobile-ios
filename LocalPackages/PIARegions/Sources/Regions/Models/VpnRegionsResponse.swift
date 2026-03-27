/*
 *  Copyright (c) 2020 Private Internet Access, Inc.
 *
 *  This file is part of the Private Internet Access Mobile Client.
 *
 *  The Private Internet Access Mobile Client is free software: you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as published by the Free
 *  Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  The Private Internet Access Mobile Client is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *  details.
 *
 *  You should have received a copy of the GNU General Public License along with the Private
 *  Internet Access Mobile Client.  If not, see <https://www.gnu.org/licenses/>.
 */

import Foundation

public struct VPNRegionsResponse: Codable, Sendable {
    public var groups: [String: [ProtocolDetails]]
    public var regions: [Region]

    public init(groups: [String: [ProtocolDetails]] = [:], regions: [Region] = []) {
        self.groups = groups
        self.regions = regions
    }

    public struct ProtocolDetails: Codable, Sendable {
        public var name: String
        public var ports: [Int]

        public init(name: String = "", ports: [Int] = []) {
            self.name = name
            self.ports = ports
        }
    }

    public struct Region: Codable, Sendable {
        public var id: String
        public var name: String
        public var country: String
        public var dns: String
        public var geo: Bool
        public var offline: Bool
        public var latitude: String?
        public var longitude: String?
        public var autoRegion: Bool
        public var portForward: Bool
        public var servers: [String: [ServerDetails]]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case country
            case dns
            case geo
            case offline
            case latitude
            case longitude
            case autoRegion = "auto_region"
            case portForward = "port_forward"
            case servers
        }

        public init(
            id: String = "",
            name: String = "",
            country: String = "",
            dns: String = "",
            geo: Bool = false,
            offline: Bool = false,
            latitude: String? = nil,
            longitude: String? = nil,
            autoRegion: Bool = false,
            portForward: Bool = false,
            servers: [String: [ServerDetails]] = [:]
        ) {
            self.id = id
            self.name = name
            self.country = country
            self.dns = dns
            self.geo = geo
            self.offline = offline
            self.latitude = latitude
            self.longitude = longitude
            self.autoRegion = autoRegion
            self.portForward = portForward
            self.servers = servers
        }

        public struct ServerDetails: Codable, Sendable {
            public var ip: String
            public var cn: String

            public init(ip: String = "", cn: String = "") {
                self.ip = ip
                self.cn = cn
            }
        }
    }
}
