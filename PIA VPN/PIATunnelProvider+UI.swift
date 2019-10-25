//
//  PIATunnelProvider+UI.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import TunnelKit

extension SocketType: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

extension OpenVPN.Cipher: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

extension OpenVPN.Digest: CustomStringConvertible {
    public var description: String {
        return "HMAC-\(rawValue)"
    }
}
