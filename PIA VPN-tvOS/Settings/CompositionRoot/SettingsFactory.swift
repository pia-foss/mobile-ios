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
        return AvailableSettingsViewModel(onAccountSelectedAction: AppRouter.navigateToAccountSettingsDestinationAction, 
                                          onDedicatedIpSectionSelectedAction: AppRouter.navigateToDIPSettingsDestinationAction)
    }
    
    static func makeAvailableSettingsView() -> AvailableSettingsView {
        return AvailableSettingsView(viewModel: makeAvailableSettingsViewModel())
    }
    
    static func makeDefaultAccountProvider() -> AccountProviderType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        return defaultAccountProvider
    }
    
    static func makeLogOutUseCase() -> LogOutUseCaseType {
        return LogOutUseCase(accountProvider: makeDefaultAccountProvider(),
                             appPreferences: AppPreferences.shared,
                             vpnConfigurationProvicer: VPNConfigurationInstallingFactory.makeVpnConfigurationProvider(),
                             vpnConfigurationAvailability: VPNConfigurationAvailability(),
                             connectionStatsPermisson: ConnectionStatsPermisson(), clientPreferences: RegionsSelectionFactory.makeClientPreferences, favoriteRegionsUserCase: RegionsSelectionFactory.makeFavoriteRegionUseCase, searchedRegionsAvailability: RegionsSelectionFactory.makeSearchedRegionsAvailability())
    }
    
    private static func makeAccountSettingsViewModel() -> AccountSettingsViewModel {
        return AccountSettingsViewModel(accountProvider: makeDefaultAccountProvider(), logOutUseCase: makeLogOutUseCase())
    }
    
    static func makeAccountSettingsView() -> AccountSettingsView {
        return AccountSettingsView(viewModel: makeAccountSettingsViewModel())
    }
}
