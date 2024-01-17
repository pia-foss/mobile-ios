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
    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    static func makeVPNConfigurationInstallingView() -> VPNConfigurationInstallingView {
        VPNConfigurationInstallingView(viewModel: makeVPNConfigurationInstallingViewModel())
    }
    
    private static func makeVPNConfigurationInstallingViewModel() -> VPNConfigurationInstallingViewModel {
        VPNConfigurationInstallingViewModel(installVPNConfiguration: 
                                                makeInstallVPNConfigurationUseCase(), 
                                            errorMapper: VPNConfigurationInstallingErrorMapper(),
                                            appRouter: AppRouter.shared, onSuccessAction: .goBackToRoot)
    }
    
    private static func makeInstallVPNConfigurationUseCase() -> InstallVPNConfigurationUseCaseType {
        
        guard !isSimulator else {
            return InstallVPNConfigurationUseCaseMock(error: nil)
        }
        
        return InstallVpnConfigurationProvider(vpnProvider:  makeVpnConfigurationProvider(),
                                        vpnConfigurationAvailability: VPNConfigurationAvailability())
    }
    
    private static func makeVpnConfigurationProvider() -> VpnConfigurationProviderType {
        return VpnConfigurationProvider(vpnProvider: Client.providers.vpnProvider)
        
    }
}
