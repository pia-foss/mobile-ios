//
//  PIATunnelProvider+Profile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 1/11/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import TunnelKit

/// :nodoc:
extension OpenVPNTunnelProvider.Configuration: VPNCustomConfiguration {
    public func serialized() -> [String: Any] {
        return generatedProviderConfiguration(appGroup: Client.Configuration.appGroup)
    }
    
    public func isEqual(to: VPNCustomConfiguration) -> Bool {
        guard let other = to as? OpenVPNTunnelProvider.Configuration else {
            return false
        }
        guard (mtu == other.mtu) else {
            return false
        }
        guard (shouldDebug == other.shouldDebug) else {
            return false
        }
        guard self.builder().build().generatedProviderConfiguration(appGroup: Client.Configuration.appGroup).description == other.builder().build().generatedProviderConfiguration(appGroup: Client.Configuration.appGroup).description else {
            return false
        }
        return true
    }
}
