//
//  AvailableSettingsViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALocalizations

class AvailableSettingsViewModel: ObservableObject {
    enum Sections: Equatable, Hashable, Identifiable {
        case account
        case general
        case dedicatedIp
        case protocols

        var id: Self {
            return self
        }

        var title: String {
            switch self {
            case .account:
                return L10n.Menu.Item.account
            case .general:
                return L10n.Global.General.settings
            case .dedicatedIp:
                return L10n.Dedicated.Ip.title
            case .protocols:
                return L10n.Settings.Section.protocols
            }
        }
    }

    let sections: [Sections]

    private let onAccountSectionSelectedAction: AppRouter.Actions
    private let onDedicatedIpSectionSelectedAction: AppRouter.Actions
    private let onProtocolSectionSelectedAction: AppRouter.Actions

    init(onAccountSelectedAction: AppRouter.Actions, onDedicatedIpSectionSelectedAction: AppRouter.Actions, onProtocolSectionSelectedAction: AppRouter.Actions) {
        self.onAccountSectionSelectedAction = onAccountSelectedAction
        self.onDedicatedIpSectionSelectedAction = onDedicatedIpSectionSelectedAction
        self.onProtocolSectionSelectedAction = onProtocolSectionSelectedAction
        self.sections = [.account, .protocols, .dedicatedIp]
    }

    func navigate(to section: Sections) {
        switch section {
        case .account:
            onAccountSectionSelectedAction()
        case .general:
            // TODO: Implement me
            break
        case .dedicatedIp:
            onDedicatedIpSectionSelectedAction()
            break
        case .protocols:
            onProtocolSectionSelectedAction()
        }
    }

}
