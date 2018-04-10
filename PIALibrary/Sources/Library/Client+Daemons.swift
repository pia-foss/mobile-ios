//
//  Client+Daemons.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

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
            return accessedDatabase.transient.publicIP
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
