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
import TunnelKitCore
import TunnelKitOpenVPN
import PIAWireguard

public extension String {
    
    var vpnProtocol: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "WireGuard®"
        case PIATunnelProfile.vpnType:
            return "OpenVPN"
        case IKEv2Profile.vpnType:
            return "IPSec (IKEv2)"
        default:
            return self
        }
    }
    
    var port: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "1337"
        case PIATunnelProfile.vpnType:
            if AppPreferences.shared.piaSocketType != nil {
                let preferences = Client.preferences.editable()
                if let currentOpenVPNConfiguration = preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNProvider.Configuration {
                    let port = currentOpenVPNConfiguration.sessionConfiguration.builder().endpointProtocols?.first?.port ?? 0
                    return "\(port)"
                }
            } else {
                return L10n.Global.automatic
            }
            return "---"
        case IKEv2Profile.vpnType:
            return "500"
        default:
            return "---"
        }
    }
    
    var socket: String {
        switch self {
        case PIAWGTunnelProfile.vpnType, IKEv2Profile.vpnType:
            return "UDP"
        case PIATunnelProfile.vpnType:
            return AppPreferences.shared.piaSocketType?.rawValue ?? L10n.Global.automatic
        default:
            return self

        }
    }
    
    var handshake: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "Noise_IK"
        case PIATunnelProfile.vpnType:
            return AppPreferences.shared.piaHandshake.description
        case IKEv2Profile.vpnType:
            let preferences = Client.preferences.editable()
            return preferences.ikeV2IntegrityAlgorithm
        default:
            return self
        }
    }

    var encryption: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "ChaCha20"
        case PIATunnelProfile.vpnType:
            let preferences = Client.preferences.editable()
            if let currentOpenVPNConfiguration = preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNProvider.Configuration {
                return currentOpenVPNConfiguration.sessionConfiguration.builder().cipher?.rawValue ?? ""
            }
            return "---"
        case IKEv2Profile.vpnType:
            let preferences = Client.preferences.editable()
            return preferences.ikeV2EncryptionAlgorithm
        default:
            return self
        }
    }
    
    var authentication: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "Poly1305"
        case PIATunnelProfile.vpnType:
            let preferences = Client.preferences.editable()
            if let currentOpenVPNConfiguration = preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNProvider.Configuration {
                return currentOpenVPNConfiguration.sessionConfiguration.builder().digest?.rawValue ?? ""
            }
            return "---"
        case IKEv2Profile.vpnType:
            return "---"
        default:
            return self
        }
    }
    
}
