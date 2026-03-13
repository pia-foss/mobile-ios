//
//  Routes+Settings.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI
import PIALocalizations

enum SettingsDestinations: Destinations {
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
                    .withTopNavigationBar(title: L10n.Menu.Item.settings)
            case .account:
                SettingsFactory.makeAccountSettingsView()
                    .withTopNavigationBar(title: L10n.Menu.Item.settings, subtitle: L10n.Menu.Item.account)
            case .general:
                // TODO: Implement me
                EmptyView()
            case .dip:
                DedicatedIPFactory.makeDedicatedIPView()
            }
        }
    }
}
