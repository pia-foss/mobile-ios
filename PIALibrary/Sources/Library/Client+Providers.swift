//
//  Client+Providers.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/20/17.
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

extension Client {

    /// Provides concrete implementations of the business providers.
    public class Providers {
        
        /// Provides user related methods.
        public var accountProvider: AccountProvider = DefaultAccountProvider()
        
        /// Provides methods for handling the available VPN servers.
        public var serverProvider: ServerProvider = DefaultServerProvider()
        
        /// Provides methods for controlling the VPN connection.
        public var vpnProvider: VPNProvider = DefaultVPNProvider()
        
        /// Provides tiles related methods.
        public var tileProvider: TileProvider = DefaultTileProvider()

    }
}
