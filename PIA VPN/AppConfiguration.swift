//
//  AppConfiguration.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import PIALibrary
#if canImport(TunnelKitCore)
import TunnelKitCore
import TunnelKitOpenVPN
#endif
import UIKit

struct AppConfiguration {
    private static let customClientEnvironment: Client.Environment = .staging
    
    static var clientEnvironment: Client.Environment {
        return (Flags.shared.customizesClientEnvironment ? customClientEnvironment : .production)
    }
    
    struct About {
        static let copyright = "2014-2021"

        static let companyName = "Private Internet Access, Inc."
    }
    
    struct Welcome {
        static func defaultPreset() -> Preset {
            var preset = Preset()
            guard Flags.shared.customizesWelcomePreset else {
                return preset
            }
            preset.loginUsername = "p0000000"
            preset.loginPassword = "foobarbogus"
            preset.purchaseEmail = "foo@bar.com"
            preset.redeemCode = "1234-1234-1234-1234"
            preset.redeemEmail = "foo@bar.com"
            return preset
        }
    }
    
    struct VPN {
        enum Renegotiation: Int {
            case never
            
            case qa = 120 // 2 minutes
            
            case crazy = 30 // 30 seconds
            
            case production = 3600 // 1 hour
        }
        
        static let profileName = "Private Internet Access"
        
#if os(iOS)
        static let piaDefaultConfigurationBuilder: OpenVPNProvider.ConfigurationBuilder = {
            var sessionBuilder = OpenVPN.ConfigurationBuilder()
            sessionBuilder.renegotiatesAfter = piaRenegotiationInterval
            sessionBuilder.cipher = .aes128gcm
            sessionBuilder.digest = .sha256
            if let pem = AppPreferences.shared.piaHandshake.pemString() {
                sessionBuilder.ca = OpenVPN.CryptoContainer(pem: pem)
            }
            sessionBuilder.endpointProtocols = piaAutomaticProtocols
            sessionBuilder.dnsServers = []
            sessionBuilder.usesPIAPatches = true
            var builder = OpenVPNProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())            
            if AppPreferences.shared.useSmallPackets {
                builder.sessionConfiguration.mtu = AppConstants.OpenVPNPacketSize.smallPacketSize
            } else {
                builder.sessionConfiguration.mtu = AppConstants.OpenVPNPacketSize.defaultPacketSize
            }
            builder.shouldDebug = true
            return builder
        }()
        
        
        static let piaAutomaticProtocols: [EndpointProtocol] = [
//            let vpnPorts = Client.providers.serverProvider.currentServersConfiguration.vpnPorts
            EndpointProtocol(.udp, 8080),
            EndpointProtocol(.tcp, 443)
        ]
#endif

        private static let piaCustomRenegotiation: Renegotiation = .qa
        
        private static var piaRenegotiationInterval: TimeInterval {
            let reneg: Renegotiation = (Flags.shared.customizesVPNRenegotiation ? piaCustomRenegotiation : .production)
            return TimeInterval(reneg.rawValue)
        }
    }
    
    struct ClientConfiguration {
        static let webTimeout = 5000
    }

    enum ServerPing: Int { // ms
        case low = 100
        
        case medium = 200

        case high = 1000 // or timeout
        
        static func from(value: Int) -> ServerPing {
            if (value < low.rawValue) {
                return .low
            }
            if (value < medium.rawValue) {
                return .medium
            }
            return .high
        }
    }

    struct Rating {
        static let showAfterSuccessfulConnections = 3
        static let cooldownDaysThumbsDown = 14
        static let cooldownDaysThumbsUp = 14
        static let cooldownDaysDismiss = 14
        static let errorInConnectionsUntilPrompt = 1
    }

    struct UI {
        static let iPadLandscapeMargin: CGFloat = 250.0
    }

    struct Animations {
        static let duration = 0.3
    }
    
    struct DataCounter {
        static let interval = 1.0
    }

    struct Mock {
        static let accountProvider: MockAccountProvider = {
            let provider = MockAccountProvider()
            provider.mockIsUnauthorized = false
            provider.mockSignupOutcome = .success
            provider.mockRedeemOutcome = .success
            provider.mockPlan = .trial
            provider.mockIsExpiring = true
            provider.mockIsRenewable = true
            return provider
        }()
    }
}
