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
import UIKit

#if os(iOS)
#endif

struct AppConfiguration {
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
        static let profileName: String = {
            var name = "Private Internet Access"
            #if DEVELOPMENT
                name += " (DEV)"
            #endif
            return name
        }()

    }

    struct ClientConfiguration {
        static let webTimeout = 5000
    }

    enum ServerPing: Int {  // ms
        case low = 100

        case medium = 200

        case high = 1000  // or timeout

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
        static let errorInConnectionsUntilPrompt = 1
    }

    struct UI {
        static let iPadLandscapeMargin: CGFloat = 250.0
    }

    struct Animations {
        static let duration = 0.3
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
