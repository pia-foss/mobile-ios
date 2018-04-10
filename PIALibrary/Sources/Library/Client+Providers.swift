//
//  Client+Providers.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/20/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

extension Client {

    /// Provides concrete implementations of the business providers.
    public class Providers {
        
        /// Provides user related methods.
        public var accountProvider: AccountProvider = DefaultAccountProvider()
        
        /// Provides methods for handling the available VPN servers.
        public var serverProvider: ServerProvider = DefaultServerProvider()
        
        /// Provides methods for controlling the VPN connection.
        public var vpnProvider: VPNProvider = DefaultVPNProvider()
    }
}
