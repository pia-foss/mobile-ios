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
}

enum OnboardingDestinations: Destinations {
    case installVPNProfile
}

public extension View {
    func withAuthenticationRoutes() -> some View {
        self.navigationDestination(for: AuthenticationDestinations.self) { destination in
            switch destination {
                case .loginCredentials:
                    LoginFactory.makeLoginView()
            }
        }
    }
    
    func withOnboardingRoutes() -> some View {
        self.navigationDestination(for: OnboardingDestinations.self) { destination in
            switch destination {
                case .installVPNProfile:
                    VPNConfigurationInstallingFactory.makeVPNConfigurationInstallingView()
            }
        }
    }
}
