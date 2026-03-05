//
//  ServersBundle.swift
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

/// A `ServersBundle` wraps a list of `Server` with additional metadata.
public struct ServersBundle {

    /// Holds the metadata of the `ServerProvider` configuration.
    ///
    /// - Seealso: `ServerProvider.currentServersConfiguration`
    public struct Configuration {

        /// A set of available ports to connect to the VPN servers found in this configuration.
        public struct Ports {

            /// The available ports over UDP.
            public let udp: [UInt16]

            /// The available ports over TCP.
            public let tcp: [UInt16]
            
        }

        /// The available ports for OpenVPN.
        public let ovpnPorts: Ports

        /// The available ports for WireGuard.
        public let wgPorts: Ports
        
        /// The available ports for IKEv2.
        public let ikev2Ports: Ports

        /// Deprecated
        let latestVersion: Int
        
        /// Deprecated
        let pollInterval: Int
        
        /// Deprecated
        let automaticIdentifiers: Set<String>?
    }
    
    /// The list of available `Server`s.
    public let servers: [Server]
    
    let configuration: Configuration?
}
