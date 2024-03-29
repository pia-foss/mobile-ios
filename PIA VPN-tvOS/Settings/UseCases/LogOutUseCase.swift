//
//  LogOutUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
protocol LogOutUseCaseType {
    func logOut() async throws
}

class LogOutUseCase: LogOutUseCaseType {
    let accountProvider: AccountProviderType
    let appPreferences: AppPreferencesType
    let vpnConfigurationProvider: VpnConfigurationProviderType
    let vpnConfigurationAvailability: VPNConfigurationAvailabilityType
    let connectionStatsPermisson: ConnectionStatsPermissonType
    var clientPreferences: ClientPreferencesType
    let favoriteRegionsUseCase: FavoriteRegionUseCaseType
    let searchedRegionsAvailability: SearchedRegionsAvailabilityType
    
    init(accountProvider: AccountProviderType, appPreferences: AppPreferencesType, vpnConfigurationProvicer: VpnConfigurationProviderType, vpnConfigurationAvailability: VPNConfigurationAvailabilityType,
         connectionStatsPermisson: ConnectionStatsPermissonType, clientPreferences: ClientPreferencesType, favoriteRegionsUserCase: FavoriteRegionUseCaseType, searchedRegionsAvailability: SearchedRegionsAvailabilityType) {
        self.accountProvider = accountProvider
        self.appPreferences = appPreferences
        self.vpnConfigurationProvider = vpnConfigurationProvicer
        self.vpnConfigurationAvailability = vpnConfigurationAvailability
        self.connectionStatsPermisson = connectionStatsPermisson
        self.clientPreferences = clientPreferences
        self.favoriteRegionsUseCase = favoriteRegionsUserCase
        self.searchedRegionsAvailability = searchedRegionsAvailability
    }
    
    private func uninstallVpnConfiguration() async {
        return await withCheckedContinuation { continuation in
            guard self.vpnConfigurationAvailability.get() else {
                self.connectionStatsPermisson.set(value: nil)
                continuation.resume()
                return
            }
            
            vpnConfigurationProvider.uninstall { _ in
                self.vpnConfigurationAvailability.set(value: false)
                self.connectionStatsPermisson.set(value: nil)
                continuation.resume()
            }
        }
    }
    
    private func logoutUser() async {
        return await withCheckedContinuation { continuation in
            accountProvider.logout { error in
                continuation.resume()
            }
        }
    }
    
    func logOut() async {
        await uninstallVpnConfiguration()
        await logoutUser()
        favoriteRegionsUseCase.eraseAllFavorites()
        searchedRegionsAvailability.eraseAll()
        appPreferences.reset()
        clientPreferences.selectedServer = SelectedServerUseCase.automaticServer()
        
    }
}
