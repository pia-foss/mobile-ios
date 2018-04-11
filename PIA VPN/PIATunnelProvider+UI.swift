//
//  PIATunnelProvider+UI.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIATunnel

extension PIATunnelProvider.Cipher: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

extension PIATunnelProvider.Digest: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

extension PIATunnelProvider.Handshake: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}
