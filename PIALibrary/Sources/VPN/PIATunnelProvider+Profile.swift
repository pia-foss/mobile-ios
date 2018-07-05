//
//  PIATunnelProvider+Profile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 1/11/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import PIATunnel

/// :nodoc:
extension PIATunnelProvider.Configuration: VPNCustomConfiguration {
    public func serialized() -> [String: Any] {
        return generatedProviderConfiguration()
    }
    
    public func isEqual(to: VPNCustomConfiguration) -> Bool {
        guard let other = to as? PIATunnelProvider.Configuration else {
            return false
        }
        guard (appGroup == other.appGroup) else {
            return false
        }
        guard (endpointProtocols == other.endpointProtocols) else {
            return false
        }
        guard (cipher == other.cipher) else {
            return false
        }
        guard (digest == other.digest) else {
            return false
        }
        guard (handshake == other.handshake) else {
            return false
        }
        guard (mtu == other.mtu) else {
            return false
        }
        // XXX: this may be incorrectly false if both are nil
        guard (renegotiatesAfterSeconds == other.renegotiatesAfterSeconds) else {
            return false
        }
        guard (shouldDebug == other.shouldDebug) else {
            return false
        }
        guard (debugLogKey == other.debugLogKey) else {
            return false
        }
        return true
    }
}
