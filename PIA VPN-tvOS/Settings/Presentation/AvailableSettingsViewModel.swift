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
        
        // TODO: Localize
        var title: String {
            switch self {
            case .account:
                return "Account"
            case .general:
                return "General Settings"
            case .dedicatedIp:
                return "Dedicated IP"
            }
        }
    }
    
    var sections: [Sections] = [.account]
    
    
    
}
