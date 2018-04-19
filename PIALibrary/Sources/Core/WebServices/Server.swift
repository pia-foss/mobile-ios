//
//  Server.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/10/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Possible errors raised when parsing a `Server`.
public enum ServerError: Error {

    /// The server address format is incorrect.
    case addressFormat
}

/// Represents a VPN server.
public class Server: Hashable {

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
    
    /// The server name.
    public let name: String
    
    /// The server country code.
    public let country: String
    
    /// The server hostname.
    public let hostname: String
    
    /// The server identifier.
    public let identifier: String
    
    /// The best address for establishing an OpenVPN connection over TCP.
    public let bestOpenVPNAddressForTCP: Address?

    /// The best address for establishing an OpenVPN connection over UDP.
    public let bestOpenVPNAddressForUDP: Address?
    
    /// The address on which to "ping" the server.
    ///
    /// - Seealso: `Macros.ping(...)`
    public let pingAddress: Address?

    var isAutomatic: Bool

    /// :nodoc:
    public init(
        name: String,
        country: String,
        hostname: String,
        bestOpenVPNAddressForTCP: Address?,
        bestOpenVPNAddressForUDP: Address?,
        pingAddress: Address?) {
        
        self.name = name
        self.country = country
        self.hostname = hostname
        identifier = hostname.components(separatedBy: ".").first ?? ""
        self.bestOpenVPNAddressForTCP = bestOpenVPNAddressForTCP
        self.bestOpenVPNAddressForUDP = bestOpenVPNAddressForUDP
        self.pingAddress = pingAddress
        
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
