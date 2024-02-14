//
//  SettingsFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class SettingsFactory {
    static func makeAvailableSettingsViewModel() -> AvailableSettingsViewModel {
        return AvailableSettingsViewModel()
    }
    
    static func makeAvailableSettingsView() -> AvailableSettingsView {
        return AvailableSettingsView(viewModel: makeAvailableSettingsViewModel())
    }
}
