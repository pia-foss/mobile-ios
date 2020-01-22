//
//  PemUtil.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 06/11/2019.
//  Copyright © 2020 Private Internet Access Inc.
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
import TunnelKit

public extension OpenVPN.Configuration {
    
    /// The available certificates for handshake.
    enum Handshake: String, Codable, CustomStringConvertible {
        
        /// Certificate with RSA 2048-bit key.
        case rsa2048 = "RSA-2048"
        
        /// Certificate with RSA 3072-bit key.
        case rsa3072 = "RSA-3072"

        /// Certificate with RSA 4096-bit key.
        case rsa4096 = "RSA-4096"
        
        /// Certificate with ECC based on secp256r1 curve.
        case ecc256r1 = "ECC-256r1"
        
        /// Certificate with ECC based on secp256k1 curve.
        case ecc256k1 = "ECC-256k1"

        /// Certificate with ECC based on secp521r1 curve.
        case ecc521r1 = "ECC-521r1"
        
        /// Custom certificate.
        ///
        /// - Seealso:
        case custom = "Custom"
        
        static let allDigests: [Handshake: String] = [
            .rsa2048: "e2fccccaba712ccc68449b1c56427ac1",
            .rsa3072: "2fcdb65712df9db7dae34a1f4a84e32d",
            .rsa4096: "ec085790314aa0ad4b01dda7b756a932",
            .ecc256r1: "6f0f23a616479329ce54614f76b52254",
            //.ecc256k1: "80c3b0f34001e4101e34fde9eb1dfa87",
            .ecc521r1: "82446e0c80706e33e6e793cebf1b0c59"
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
                fatalError("Could not find \(certName) TLS certificate")
            }
            let content = try String(contentsOf: certUrl)
            try content.write(to: url, atomically: true, encoding: .ascii)
        }
        
        func pemString() -> String? {
            let bundle = Bundle.main
            let certName = "PIA-\(rawValue)"
            guard let certUrl = bundle.url(forResource: certName, withExtension: "pem") else {
                fatalError("Could not find \(certName) TLS certificate")
            }
            do {
                return try String(contentsOf: certUrl)
            } catch {
                return nil
            }
        }
        
        /// :nodoc:
        public var description: String {
            return "\(rawValue)"
        }
    }
    
}
