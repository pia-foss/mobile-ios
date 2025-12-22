//
//  PemUtil.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 06/11/2019.
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
import TunnelKitCore
import TunnelKitOpenVPN
import PIALibrary

private let log = PIALogger.logger(for: OpenVPN.Configuration.self)

public extension OpenVPN.Configuration {

    enum ConfigurationError: Error, LocalizedError {
        /// Unable to find required resource file
        case resourceNotFound(String)

        public var errorDescription: String? {
            switch self {
            case .resourceNotFound(let name):
                "Required resource not found: \(name)"
            }
        }
    }
    
    /// The available certificates for handshake.
    enum Handshake: String, Codable, CustomStringConvertible {
        
        /// Certificate with RSA 4096-bit key.
        case rsa4096 = "RSA-4096"
        
        /// Custom certificate.
        ///
        /// - Seealso:
        case custom = "Custom"
        
        static let allDigests: [Handshake: String] = [
            .rsa4096: "ec085790314aa0ad4b01dda7b756a932"
        ]
        
        var digest: String? {
            return Handshake.allDigests[self]
        }
        
        func write(to url: URL, custom: String? = nil) throws {
            precondition((self != .custom) || (custom != nil))
            
            // custom certificate?
            if self == .custom, let content = custom {
                try content.write(to: url, atomically: true, encoding: .ascii)
                return
            }

            let bundle = Bundle.main
            let certName = "PIA-\(rawValue)"
            guard let certUrl = bundle.url(forResource: certName, withExtension: "pem") else {
                log.error("Could not find \(certName) TLS certificate in bundle")
                throw ConfigurationError.resourceNotFound(certName)
            }
            let content = try String(contentsOf: certUrl)
            try content.write(to: url, atomically: true, encoding: .ascii)
        }
        
        func pemString() -> String? {
            let bundle = Bundle.main
            let certName = "PIA-\(rawValue)"
            guard let certUrl = bundle.url(forResource: certName, withExtension: "pem") else {
                log.error("Could not find \(certName) TLS certificate in bundle")
                return nil
            }
            do {
                return try String(contentsOf: certUrl)
            } catch {
                log.error("Could not read \(certName) TLS certificate: \(error)")
                return nil
            }
        }
        
        /// :nodoc:
        public var description: String {
            return "\(rawValue)"
        }
    }
    
}
