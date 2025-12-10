//
//  Server.swift
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

/// Possible errors raised when parsing a `Server`.
public enum ServerError: Error {

    /// The server address format is incorrect.
    case addressFormat
}

/// Represents a VPN server.
public class Server: Hashable {

    /// Serial host
    public let serial: String

    /// Represents a VPN server address endpoint.
    public struct Address: CustomStringConvertible {
        
        /// The endpoint hostname.
        public let hostname: String
        
        /// The endpoint port.
        public let port: UInt16

        /// :nodoc:
        public init(hostname: String, port: UInt16) {
            self.hostname = hostname
            self.port = port
        }

        /**
         Convenience initializer from compound string.

         - Parameter string: An address string in the "hostname:port" format.
         - Throws `ServerError.addressFormat` if `string` format is incorrect.
         */
        public init(string: String) throws {
            let components = string.components(separatedBy: ":")
            guard (components.count == 2) else {
                throw ServerError.addressFormat
            }
            // TODO: check string format (0-255)(.0-255){3}:(0-65535)
            hostname = components[0]
            guard let port = UInt16(components[1]) else {
                throw ServerError.addressFormat
            }
            self.port = port
        }

        /// :nodoc:
        public var description: String {
            return "\(hostname):\(port)"
        }
    }
    
    /// Represents a VPN server IP endpoint.
    public class ServerAddressIP: Codable {
        
        /// The endpoint ip.
        public let ip: String
        
        /// The endpoint common name.
        public let cn: String
        
        /// The server is using the latest OVPN version.
        public let van: Bool

        /// The response time for this address.
        private(set) var responseTime: Int?
        
        private(set) var available: Bool = true
        
        public var description: String {
            return "\(ip):0"
        }
        
        /// :nodoc:
        public init(ip: String, cn: String, van: Bool) {
            self.ip = ip
            self.cn = cn
            self.van = van
        }
        
        func updateResponseTime(_ time: Int) {
            self.responseTime = time
        }
        
        func markServerAsUnavailable() {
            available = false
        }
        
        func reset() {
            available = true
        }

    }
    
    /// The server name.
    public let name: String
    
    /// The server country code.
    public let country: String
    
    /// The server hostname.
    public let hostname: String
    
    /// The server identifier.
    public let identifier: String
    
    /// The server region identifier
    public let regionIdentifier: String
    
    /// The server is virtually located.
    public let geo: Bool

    /// The server is unavailable.
    public let offline: Bool

    /// The server's latitude.
    public let latitude: String?

    /// The server's longitude.
    public let longitude: String?
    
    /// The best address for establishing an OpenVPN connection over TCP.
    public let openVPNAddressesForTCP: [ServerAddressIP]?

    /// The best address for establishing an OpenVPN connection over UDP.
    public let openVPNAddressesForUDP: [ServerAddressIP]?

    /// The best server IPs for establishing a WireGuard connection over UDP.
    public let wireGuardAddressesForUDP: [ServerAddressIP]?
    
    /// The best server IPs for establishing an IKEv2 connection over UDP.
    public let iKEv2AddressesForUDP: [ServerAddressIP]?
        
    /// The address on which to "ping" the server.
    ///
    /// - Seealso: `Macros.ping(...)`
    public let pingAddress: Address?

    /// The meta IP.
    public let meta: ServerAddressIP?

    public let dipExpire: Date?
    
    public let dipToken: String?
    
    public let dipStatus: DedicatedIPStatus?
    
    public let dipUsername: String?

    var isAutomatic: Bool

    /// :nodoc:
    public init(
        serial: String,
        name: String,
        country: String,
        hostname: String,
        openVPNAddressesForTCP: [ServerAddressIP]? = nil,
        openVPNAddressesForUDP: [ServerAddressIP]? = nil,
        wireGuardAddressesForUDP: [ServerAddressIP]? = nil,
        iKEv2AddressesForUDP: [ServerAddressIP]? = nil,
        pingAddress: Address?,
        responseTime: Int? = 0,
        geo: Bool = false,
        offline: Bool = false,
        latitude: String? = nil,
        longitude: String? = nil,
        meta: ServerAddressIP? = nil,
        dipExpire: Date? = nil,
        dipToken: String? = nil,
        dipStatus: DedicatedIPStatus? = nil,
        dipUsername: String? = nil,
        regionIdentifier: String) {
        
        self.serial = serial
        self.name = name
        self.country = country
        self.hostname = hostname
        self.geo = geo
        self.offline = offline
        self.latitude = latitude
        self.longitude = longitude
        self.regionIdentifier = regionIdentifier
        identifier = hostname.components(separatedBy: ".").first ?? ""
        
        self.openVPNAddressesForTCP = openVPNAddressesForTCP
        self.openVPNAddressesForUDP = openVPNAddressesForUDP
        self.wireGuardAddressesForUDP = wireGuardAddressesForUDP
        self.iKEv2AddressesForUDP = iKEv2AddressesForUDP

        self.meta = meta
        self.pingAddress = pingAddress

        self.dipExpire = dipExpire
        self.dipToken = dipToken
        self.dipStatus = dipStatus
        self.dipUsername = dipUsername
        
        isAutomatic = false
    }
    
    // MARK: Hashable
    
    /// :nodoc:
    public static func ==(lhs: Server, rhs: Server) -> Bool {
        return (lhs.identifier == rhs.identifier && lhs.dipToken == rhs.dipToken)
    }
    
    /// :nodoc:
    public var hashValue: Int {
        return identifier.hashValue
    }
    
}

@available(tvOS 17.0, *)
extension Server {
    
    public func addresses() -> [ServerAddressIP] {
        
        switch Client.providers.vpnProvider.currentVPNType {
        case IKEv2Profile.vpnType:
            return iKEv2AddressesForUDP ?? []
        #if os(iOS)
        case PIATunnelProfile.vpnType:
            return openVPNAddressesForTCP ?? []
        case PIAWGTunnelProfile.vpnType:
            return wireGuardAddressesForUDP ?? []
        #endif
        case "Mock":
            return iKEv2AddressesForUDP ?? []
        default:
            return []
        }

    }
    
    public func ovpnAddresses(tcp: Bool) -> [ServerAddressIP] {
        
        if tcp {
            return openVPNAddressesForTCP ?? []
        } else {
            return openVPNAddressesForUDP ?? []
        }

    }
    
    public func bestAddress() -> ServerAddressIP? {
        guard !addresses().isEmpty else {
            return nil
        }
        let availableServer = addresses().first(where: {$0.available})
        if availableServer == nil {
            addresses().map({$0.reset()})
            return bestAddress()
        }
        return availableServer
    }
    
    public func bestAddressForOVPN(tcp: Bool) -> ServerAddressIP? {
        guard !ovpnAddresses(tcp: tcp).isEmpty else {
            return nil
        }
        let availableServer = ovpnAddresses(tcp: tcp).first(where: {$0.available})
        if availableServer == nil {
            ovpnAddresses(tcp: tcp).map({$0.reset()})
            return bestAddress()
        }
        return availableServer
    }
}

@available(tvOS 17.0, *)
extension Server {
    
    func updateResponseTime(_ time: Int, forAddress address: ServerAddressIP) {
        switch Client.providers.vpnProvider.currentVPNType {
        case IKEv2Profile.vpnType:
            let serverAddressIP = iKEv2AddressesForUDP?.first(where: {$0.ip == address.ip })
            serverAddressIP?.updateResponseTime(time)
        #if os(iOS)
        case PIATunnelProfile.vpnType:
            let serverAddressIP = openVPNAddressesForUDP?.first(where: {$0.ip == address.ip })
            serverAddressIP?.updateResponseTime(time)
        case PIAWGTunnelProfile.vpnType:
            let serverAddressIP = wireGuardAddressesForUDP?.first(where: {$0.ip == address.ip })
            serverAddressIP?.updateResponseTime(time)
        #endif
        default:
            break
        }
    }
    
}

@available(tvOS 17.0, *)
extension Server {
        
    func dipPassword() -> Data? {
        if let dipUsername = dipUsername {
            return Client.database.secure.passwordReference(forDipToken: dipUsername)
        }
        return nil
    }
    
}
