//
//  AppConfiguration.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary
import PIATunnel

struct AppConfiguration {
    private static let customClientEnvironment: Client.Environment = .staging
    
    static var clientEnvironment: Client.Environment {
        return (Flags.shared.customizesClientEnvironment ? customClientEnvironment : .production)
    }
    
    struct About {
        static let copyright = "2014-2018"

        static let companyName = "London Trust Media, Inc."
    }
    
    struct Welcome {
        static func defaultPreset() -> PIAWelcomeViewController.Preset {
            var preset = PIAWelcomeViewController.Preset()
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

        static let piaDefaultConfigurationBuilder: PIATunnelProvider.ConfigurationBuilder = {
            var builder = PIATunnelProvider.ConfigurationBuilder(appGroup: AppConstants.appGroup)
            builder.renegotiatesAfterSeconds = piaRenegotiationInterval
            builder.cipher = .aes128cbc
            builder.digest = .sha1
            builder.handshake = .rsa2048
            builder.mtu = 1400
            builder.shouldDebug = true
            builder.debugLogKey = "LastVPNLog"
            return builder
        }()

        private static let piaCustomRenegotiation: Renegotiation = .qa
        
        private static var piaRenegotiationInterval: Int {
            let reneg: Renegotiation = (Flags.shared.customizesVPNRenegotiation ? piaCustomRenegotiation : .production)
            return reneg.rawValue
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

        // don't prompt on usage
        static let usesUntilPrompt: UInt = .max

        // prompt after 3 successful connections
        static let eventsUntilPrompt: UInt = 3

        // prompt after at least 3 days
        static let daysUntilPrompt: Float = 3.0
        
        // prompt again after 1 day
        static let remindPeriod: Float = 1.0
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
            provider.mockSignupOutcome = .internetUnreachable
            provider.mockPlan = .trial
            provider.mockIsExpiring = true
            provider.mockIsRenewable = true
            return provider
        }()
    }
}
