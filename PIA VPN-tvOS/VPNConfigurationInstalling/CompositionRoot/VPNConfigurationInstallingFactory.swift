//
//  VPNConfigurationInstallingFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class VPNConfigurationInstallingFactory {
    static func makeVPNConfigurationInstallingView() -> VPNConfigurationInstallingView {
        VPNConfigurationInstallingView(viewModel: makeVPNConfigurationInstallingViewModel())
    }
    
    private static func makeVPNConfigurationInstallingViewModel() -> VPNConfigurationInstallingViewModel {
        VPNConfigurationInstallingViewModel(installVPNConfiguration: 
                                                makeInstallVPNConfigurationUseCase(), 
                                            errorMapper: VPNConfigurationInstallingErrorMapper(),
                                            appRouter: AppRouter.shared,
                                            successDestination: OnboardingDestinations.dashboard)
    }
    
    private static func makeInstallVPNConfigurationUseCase() -> InstallVPNConfigurationUseCaseType {
        InstallVpnConfigurationProvider(vpnProvider:  makeVpnConfigurationProvider(),
                                        vpnConfigurationAvailability: VPNConfigurationAvailability())
    }
    
    private static func makeVpnConfigurationProvider() -> VpnConfigurationProviderType {
        VpnConfigurationProvider(vpnProvider: Client.providers.vpnProvider)
    }
}
