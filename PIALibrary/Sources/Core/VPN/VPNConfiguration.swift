//
//  VPNConfiguration.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Abstract representation of a standard VPN configuration.
public struct VPNConfiguration {

    /// The name of this configuration.
    public let name: String
    
    /// The username for authentication.
    public let username: String

    /// The password reference in the keychain.
    public let passwordReference: Data

    /// The `Server` to connect to.
    public let server: Server

    /// When `true`, the VPN will connect on demand.
    public let isOnDemand: Bool

    /// When `true`, the VPN will disconnect on device sleep.
    public let disconnectsOnSleep: Bool

    /// An optional custom configuration.
    ///
    /// - Seealso: `VPNCustomConfiguration`
    public let customConfiguration: VPNCustomConfiguration?
}

/// Holds the configuration parameters of a custom VPN profile.
///
/// - Seealso: `VPNProfile`
public protocol VPNCustomConfiguration {

    /**
     Returns a dictionary representation of this configuration.

     - Returns: A hash map with the raw parameters of this configuration.
     */
    func serialized() -> [String: Any]
    
    /// :nodoc:
    func isEqual(to: VPNCustomConfiguration) -> Bool
}
