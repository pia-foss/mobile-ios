//
//  Routes+HelpSettings.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

enum HelpDestinations: Destinations {
    case root
    case about
    case acknowledments
    case privacyPolicy
}

extension View {
    func withHelpRoutes() -> some View {
        self.navigationDestination(for: HelpDestinations.self) { destination in
            switch destination {
            case .root:
                HelpFactory.makeHelpOptionsView()
                    .withTopNavigationBar(title: L10n.Localizable.Settings.Section.help)
            case .about:
                HelpFactory.makeAboutOptionsView()
                    .withTopNavigationBar(title: L10n.Localizable.Settings.Section.help, subtitle: L10n.Localizable.Menu.Item.about)
            case .acknowledments:
                EmptyView()
            case .privacyPolicy:
                EmptyView()
            }
        }
    }
}
