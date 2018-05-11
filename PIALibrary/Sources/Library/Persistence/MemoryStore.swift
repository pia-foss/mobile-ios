//
//  MemoryStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import SwiftyBeaver

private let log = SwiftyBeaver.self

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
}
