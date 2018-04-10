//
//  TransientStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol TransientStore: class {

    // MARK: Server

    var serversConfiguration: ServersBundle.Configuration { get set }

    // MARK: VPN

    var activeVPNProfile: VPNProfile? { get set }
    
    var vpnStatus: VPNStatus { get set }
    
    // MARK: Connectivity

    var isNetworkReachable: Bool { get set }
    
    var isInternetReachable: Bool { get set }
    
    var publicIP: String? { get set }
    
    var vpnIP: String? { get set }
}
