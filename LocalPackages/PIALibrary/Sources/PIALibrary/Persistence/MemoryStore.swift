//
//  MemoryStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

@available(tvOS 17.0, *)
class MemoryStore: TransientStore, ConfigurationAccess {
    
    // MARK: Server
    
    private var internalServersConfiguration: ServersBundle.Configuration?

    var serversConfiguration: ServersBundle.Configuration {
        get {
            return internalServersConfiguration ?? accessedConfiguration.defaultServersConfiguration
        }
        set {
            internalServersConfiguration = newValue
        }
    }
    
    // MARK: VPN

    var activeVPNProfile: VPNProfile?

    var vpnStatus: VPNStatus = .disconnected {
        didSet {
            guard (vpnStatus != oldValue) else {
                return
            }
            log.debug("VPN status: \(oldValue) -> \(vpnStatus)")
            Macros.postNotification(.PIADaemonsDidUpdateVPNStatus, [
                .vpnStatus: vpnStatus
            ])
        }
    }
    
    // MARK: Connectivity
    
    var isNetworkReachable = false
    
    var isInternetReachable = true
    
    var publicIP: String?
    
    var vpnIP: String?

    var vpnLog: String = ""
}
