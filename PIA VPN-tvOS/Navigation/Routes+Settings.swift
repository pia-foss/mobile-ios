//
//  Routes+Settings.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

enum SettingsDestinations {
    case availableSettings
    case account
    case general
    case dip
}




extension View {
    func withSettingsRoutes() -> some View {
        self.navigationDestination(for: SettingsDestinations.self) { destination in
            switch destination {
            case .availableSettings:
                SettingsFactory.makeAvailableSettingsView()
                    .withTopNavigationBar(with: "Settings")
            case .account:
                SettingsFactory.makeAccountSettingsView()
                    .withTopNavigationBar(with: "Account")
            case .general:
                // TODO: Implement me
                EmptyView()
            case .dip:
                // TODO: Implement me
                EmptyView()
            }
        }
    }
}
