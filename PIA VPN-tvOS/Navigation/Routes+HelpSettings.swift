//
//  Routes+HelpSettings.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI
import PIALocalizations

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
                    .withTopNavigationBar(title: L10n.Settings.Section.help)
            case .about:
                HelpFactory.makeAboutOptionsView()
                    .withTopNavigationBar(title: L10n.Settings.Section.help, subtitle: L10n.Menu.Item.about)
            case .acknowledments:
                HelpFactory.makeAcknowledgementsView()
                    .withTopNavigationBar(title: L10n.Settings.Section.help, subtitle: L10n.HelpMenu.AboutOptions.Acknowledgements.title)
            case .privacyPolicy:
                HelpFactory.makePrivacyPolicyView()
                    .withTopNavigationBar(title: L10n.Settings.Section.help, subtitle: L10n.HelpMenu.AboutOptions.PrivacyPolicy.title)
                    
            }
        }
    }
}
