//
//  VPNStatus.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// The status of a VPN connection.
public enum VPNStatus: String {

    /// The VPN is establishing a connection.
    case connecting

    /// The VPN is connected.
    case connected
    
    /// The VPN is disconnecting.
    case disconnecting

    /// The VPN is disconnected.
    case disconnected

//    case changingServer
}
