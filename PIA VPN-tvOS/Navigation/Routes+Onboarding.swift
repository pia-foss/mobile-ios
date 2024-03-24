//
//  Routes.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 12/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

enum AuthenticationDestinations: Destinations {
    case loginCredentials
    case signup
    case loginQRCode
    case expired
}

enum OnboardingDestinations: Destinations {
    case connectionstats
    case installVPNProfile
}

public extension View {
    func withAuthenticationRoutes() -> some View {
        self.navigationDestination(for: AuthenticationDestinations.self) { destination in
            switch destination {
                case .loginCredentials:
                    LoginFactory.makeLoginView()
                case .signup:
                    SignUpFactory.makeSignupView()
                case .loginQRCode:
                    LoginQRFactory.makeLoginQRView()
                case .expired:
                    ExpiredAccountFactory.makeExpiredAccountView()
            }
        }
    }
    
    func withOnboardingRoutes() -> some View {
        self.navigationDestination(for: OnboardingDestinations.self) { destination in
            switch destination {
                case .installVPNProfile:
                    VPNConfigurationInstallingFactory.makeVPNConfigurationInstallingView()
                case .connectionstats:
                    OnboardingFactory.makeOnboardingConnectionStatsView()
            }
        }
    }
}
