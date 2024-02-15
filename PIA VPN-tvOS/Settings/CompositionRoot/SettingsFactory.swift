//
//  SettingsFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SettingsFactory {
    private static func makeAvailableSettingsViewModel() -> AvailableSettingsViewModel {
        return AvailableSettingsViewModel(onAccountSelectedAction: AppRouter.navigateToAccountSettingsDestinationAction)
    }
    
    static func makeAvailableSettingsView() -> AvailableSettingsView {
        return AvailableSettingsView(viewModel: makeAvailableSettingsViewModel())
    }
    
    static func makeLogOutUseCase() -> LogOutUseCaseType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        
        return LogOutUseCase(accountProvider: defaultAccountProvider, 
                             appPreferences: AppPreferences.shared,
                             vpnConfigurationProvicer: VPNConfigurationInstallingFactory.makeVpnConfigurationProvider(),
                             vpnConfigurationAvailability: VPNConfigurationAvailability(),
                             connectionStatsPermisson: ConnectionStatsPermisson())
    }
    
    private static func makeAccountSettingsViewModel() -> AccountSettingsViewModel {
        return AccountSettingsViewModel(logOutUseCase: makeLogOutUseCase())
    }
    
    static func makeAccountSettingsView() -> AccountSettingsView {
        return AccountSettingsView(viewModel: makeAccountSettingsViewModel())
    }
}
