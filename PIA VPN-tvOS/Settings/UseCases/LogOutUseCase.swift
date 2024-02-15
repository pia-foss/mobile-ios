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
    
    init(accountProvider: AccountProviderType, appPreferences: AppPreferencesType, vpnConfigurationProvicer: VpnConfigurationProviderType) {
        self.accountProvider = accountProvider
        self.appPreferences = appPreferences
        self.vpnConfigurationProvider = vpnConfigurationProvicer
    }
    
    private func uninstallVpnConfiguration() async {
        return await withCheckedContinuation { continuation in
            vpnConfigurationProvider.uninstall { _ in
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
        appPreferences.reset()
        await logoutUser()
        DispatchQueue.main.async {
            AppRouter.shared.goBackToRoot()
        }
        
    }
}
