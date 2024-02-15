//
//  AvailableSettingsViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class AvailableSettingsViewModel: ObservableObject {
    enum Sections: Equatable, Hashable, Identifiable {
        case account
        case general
        case dedicatedIp
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self {
            case .account:
                return L10n.Localizable.Menu.Item.account
            case .general:
                return L10n.Localizable.Global.General.settings
            case .dedicatedIp:
                return L10n.Localizable.Dedicated.Ip.title
            }
        }
    }
    
    var sections: [Sections] = [.account]
    
    private let onAccountSectionSelectedAction: AppRouter.Actions
    
    init(onAccountSelectedAction: AppRouter.Actions) {
        self.onAccountSectionSelectedAction = onAccountSelectedAction
    }
    
    func navigate(to section: Sections) {
        switch section {
        case .account:
            onAccountSectionSelectedAction.callAsFunction()
        case .general:
            // TODO: Implement me
            break
        case .dedicatedIp:
            // TODO: Implement me
            break
        }
    }
    
}
