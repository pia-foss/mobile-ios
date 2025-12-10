//
//  Client+Daemons.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
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

@available(tvOS 17.0, *)
extension Client {

    /// Provides access to passive library updates.
    public final class Daemons: DatabaseAccess {

        /// It's `true` when the network is reachable.
        public var isNetworkReachable: Bool {
            return accessedDatabase.transient.isNetworkReachable
        }
        
        /// It's `true` when the Internet is reachable.
        public var isInternetReachable: Bool {
            return accessedDatabase.transient.isInternetReachable
        }

        /// The public IP address while not on VPN.
        public var publicIP: String? {
            return accessedDatabase.plain.publicIP
        }

        /// The IP address while on VPN.
        public var vpnIP: String? {
            return accessedDatabase.transient.vpnIP
        }

        /// The status of the VPN connection.
        public var vpnStatus: VPNStatus {
            return accessedDatabase.transient.vpnStatus
        }
    }
}
