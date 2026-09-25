//
//  String+VPNType.swift
//  PIA VPN
//
//  Created by Jose Blaya on 29/09/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation
import PIALibrary
import PIALocalizations

public extension String {

    var vpnProtocol: String {
        switch self {
        case KapePlatformSDKVPNType.wireGuard.rawValue:
            return "WireGuard®"
        case KapePlatformSDKVPNType.openVPN.rawValue:
            return "OpenVPN"
        case KapePlatformSDKVPNType.automatic.rawValue:
            return L10n.Global.automatic
        default:
            return self
        }
    }

    var port: String {
        switch self {
        case KapePlatformSDKVPNType.wireGuard.rawValue:
            return "1337"
        case KapePlatformSDKVPNType.openVPN.rawValue:
            guard Client.preferences.openVPNSocketType != nil else {
                return L10n.Global.automatic
            }
            let port = Client.preferences.openVPNPort
            return port > 0 ? "\(port)" : L10n.Global.automatic
        default:
            return "---"
        }
    }

    var socket: String {
        switch self {
        case KapePlatformSDKVPNType.wireGuard.rawValue:
            return "UDP"
        case KapePlatformSDKVPNType.openVPN.rawValue:
            return Client.preferences.openVPNSocketType ?? L10n.Global.automatic
        default:
            return "---"
        }
    }

    var handshake: String {
        switch self {
        case KapePlatformSDKVPNType.wireGuard.rawValue:
            return "Noise_IK"
        case KapePlatformSDKVPNType.openVPN.rawValue:
            // The PlatformSDK tunnel pins the bundled PIA root CA for both protocols.
            return "RSA-4096"
        default:
            return "---"
        }
    }

    var encryption: String {
        switch self {
        case KapePlatformSDKVPNType.wireGuard.rawValue:
            return "ChaCha20"
        case KapePlatformSDKVPNType.openVPN.rawValue:
            return Client.preferences.openVPNCipher ?? AppConstants.OpenVPNCrypto.default.rawValue
        default:
            return "---"
        }
    }

    var authentication: String {
        switch self {
        case KapePlatformSDKVPNType.wireGuard.rawValue:
            return "Poly1305"
        case KapePlatformSDKVPNType.openVPN.rawValue:
            return Client.preferences.openVPNAuth ?? AppConstants.OpenVPNCrypto.defaultAuth
        default:
            return "---"
        }
    }

}
