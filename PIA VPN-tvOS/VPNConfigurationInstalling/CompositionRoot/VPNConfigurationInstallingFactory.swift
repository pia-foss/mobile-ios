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
                                            errorMapper: VPNConfigurationInstallingErrorMapper()) {
            AppRouter.Actions.goBackToRoot(router: AppRouter.shared)()
            NotificationCenter.default.post(name: .DidInstallVPNProfile, object: nil)
        }
    }
    
    private static func makeInstallVPNConfigurationUseCase() -> InstallVPNConfigurationUseCaseType {
        
        guard !isSimulator else {
            
            let onSuccessAction = {
                let vpnConfigurationAvailability = VPNConfigurationAvailability()
                vpnConfigurationAvailability.set(value: true)
            }
            
            return InstallVPNConfigurationUseCaseMock(error: nil, onSuccessAction: onSuccessAction)
        }
        
        return InstallVpnConfigurationProvider(vpnProvider:  makeVpnConfigurationProvider(),
                                        vpnConfigurationAvailability: VPNConfigurationAvailability())
    }
    
    private static func makeVpnConfigurationProvider() -> VpnConfigurationProviderType {
        return VpnConfigurationProvider(vpnProvider: Client.providers.vpnProvider)
        
    }
}
