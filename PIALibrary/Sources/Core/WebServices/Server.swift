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

        /// The response time for this address.
        private(set) var responseTime: Int?

        /// :nodoc:
        public init(ip: String, cn: String) {
            self.ip = ip
            self.cn = cn
        }
        
        func updateResponseTime(_ time: Int) {
            self.responseTime = time
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

    /// The best address for establishing an OpenVPN connection over TCP.
    public let bestOpenVPNAddressForTCP: Address?

    /// The best address for establishing an OpenVPN connection over UDP.
    public let bestOpenVPNAddressForUDP: Address?
    
    /// The best address for establishing an OpenVPN connection over TCP.
    public let openVPNAddressesForTCP: [ServerAddressIP]?

    /// The best address for establishing an OpenVPN connection over UDP.
    public let openVPNAddressesForUDP: [ServerAddressIP]?

    /// The best server IPs for establishing a WireGuard connection over UDP.
    public let wireGuardAddressesForUDP: [ServerAddressIP]?
    
    /// The best server IPs for establishing an IKEv2 connection over UDP.
    public let iKEv2AddressesForUDP: [ServerAddressIP]?
    
    public let serverNetwork: ServersNetwork?
    
    /// The address on which to "ping" the server.
    ///
    /// - Seealso: `Macros.ping(...)`
    public let pingAddress: Address?

    var isAutomatic: Bool

    /// :nodoc:
    public init(
        serial: String,
        name: String,
        country: String,
        hostname: String,
        bestOpenVPNAddressForTCP: Address?,
        bestOpenVPNAddressForUDP: Address?,
        openVPNAddressesForTCP: [ServerAddressIP]? = nil,
        openVPNAddressesForUDP: [ServerAddressIP]? = nil,
        wireGuardAddressesForUDP: [ServerAddressIP]? = nil,
        iKEv2AddressesForUDP: [ServerAddressIP]? = nil,
        pingAddress: Address?,
        responseTime: Int? = 0,
        serverNetwork: ServersNetwork? = .legacy,
        geo: Bool = false,
        regionIdentifier: String) {
        
        self.serial = serial
        self.name = name
        self.country = country
        self.hostname = hostname
        self.geo = geo
        self.regionIdentifier = regionIdentifier
        identifier = hostname.components(separatedBy: ".").first ?? ""
        
        self.bestOpenVPNAddressForTCP = bestOpenVPNAddressForTCP
        self.bestOpenVPNAddressForUDP = bestOpenVPNAddressForUDP
        self.openVPNAddressesForTCP = openVPNAddressesForTCP
        self.openVPNAddressesForUDP = openVPNAddressesForUDP
        self.wireGuardAddressesForUDP = wireGuardAddressesForUDP
        self.iKEv2AddressesForUDP = iKEv2AddressesForUDP

        self.pingAddress = pingAddress
        self.serverNetwork = serverNetwork

        isAutomatic = true
    }
    
    // MARK: Hashable
    
    /// :nodoc:
    public static func ==(lhs: Server, rhs: Server) -> Bool {
        return (lhs.identifier == rhs.identifier)
    }
    
    /// :nodoc:
    public var hashValue: Int {
        return identifier.hashValue
    }
    
}

extension Server {
    
    func bestAddressForOpenVPNTCP() -> Address? {
        if Client.configuration.serverNetwork == .gen4,
            let addresses = openVPNAddressesForTCP {
            let sorted = addresses.sorted(by: { $0.responseTime ?? 0 > $1.responseTime ?? 0 })
            return nil
        }
        
        return bestOpenVPNAddressForTCP

    }
    
    func bestAddressForOpenVPNUDP() -> Address? {
        if Client.configuration.serverNetwork == .gen4,
            let addresses = openVPNAddressesForUDP {
            let sorted = addresses.sorted(by: { $0.responseTime ?? 0 > $1.responseTime ?? 0 })
            return nil
        }

        return bestOpenVPNAddressForUDP

    }

    func bestAddressForIKEv2() -> ServerAddressIP? {
        
        if Client.configuration.serverNetwork == .gen4,
            let addresses = iKEv2AddressesForUDP {
            let sorted = addresses.sorted(by: { $0.responseTime ?? 0 > $1.responseTime ?? 0 })
            return sorted.first
        }

        return nil // currently using DNS
    }

    func bestAddressForWireGuard() -> ServerAddressIP? {
        if Client.configuration.serverNetwork == .gen4,
            let addresses = wireGuardAddressesForUDP {
            let sorted = addresses.sorted(by: { $0.responseTime ?? 0 > $1.responseTime ?? 0 })
            return sorted.first
        }

        return nil 
    }

    func bestPingAddress() -> [Address] {
        
        if Client.configuration.serverNetwork == .gen4 {
            switch Client.providers.vpnProvider.currentVPNType {
            case IKEv2Profile.vpnType:
                var addresses: [Address] = []
                for address in iKEv2AddressesForUDP ?? [] {
                    addresses.append(Address(hostname: address.ip, port: 0))
                }
                return addresses
            case PIATunnelProfile.vpnType:
                var addresses: [Address] = []
                for address in openVPNAddressesForUDP ?? [] {
                    addresses.append(Address(hostname: address.ip, port: 0))
                }
                return addresses
            case PIAWGTunnelProfile.vpnType:
                var addresses: [Address] = []
                for address in wireGuardAddressesForUDP ?? [] {
                    addresses.append(Address(hostname: address.ip, port: 0))
                }
                return addresses
            default:
                return []
            }
        } else if let pingAddress = pingAddress {
            return [pingAddress]
        } else {
            return []
        }
        

    }
    
}

extension Server {
    
    func updateResponseTime(_ time: Int, forAddress address: Address) {
        switch Client.providers.vpnProvider.currentVPNType {
        case IKEv2Profile.vpnType:
            let serverAddressIP = iKEv2AddressesForUDP?.first(where: {$0.ip == address.hostname })
            serverAddressIP?.updateResponseTime(time)
        case PIATunnelProfile.vpnType:
            let serverAddressIP = openVPNAddressesForUDP?.first(where: {$0.ip == address.hostname })
            serverAddressIP?.updateResponseTime(time)
        case PIAWGTunnelProfile.vpnType:
            let serverAddressIP = wireGuardAddressesForUDP?.first(where: {$0.ip == address.hostname })
            serverAddressIP?.updateResponseTime(time)
        default:
            break
        }
    }
    
}
