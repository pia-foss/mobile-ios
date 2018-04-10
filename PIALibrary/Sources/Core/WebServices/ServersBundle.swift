//
//  ServersBundle.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/10/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
        public let vpnPorts: Ports

        let latestVersion: Int
        
        let pollInterval: Int
        
        let automaticIdentifiers: Set<String>?
    }
    
    /// The list of available `Server`s.
    public let servers: [Server]
    
    let configuration: Configuration?
}
