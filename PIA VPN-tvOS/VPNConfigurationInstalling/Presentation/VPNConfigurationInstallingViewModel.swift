//
//  VPNConfigurationInstallingViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 15/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

class VPNConfigurationInstallingViewModel: ObservableObject {
    private let installVPNConfiguration: InstallVPNConfigurationUseCaseType
    private let errorMapper: VPNConfigurationInstallingErrorMapper
    private let appRouter: AppRouterType
    
    @Published var shouldShowErrorMessage = false
    @Published var installingStatus: VPNConfigurationInstallingStatus = .none
    var errorMessage: String?
    
    private let successDestination: any Destinations
    
    init(installVPNConfiguration: InstallVPNConfigurationUseCaseType, errorMapper: VPNConfigurationInstallingErrorMapper, appRouter: AppRouterType, successDestination: any Destinations) {
        self.installVPNConfiguration = installVPNConfiguration
        self.errorMapper = errorMapper
        self.appRouter = appRouter
        self.successDestination = successDestination
    }
    
    func install() {
        guard installingStatus != .isInstalling else {
            return
        }
        
        installingStatus = .isInstalling
        
        Task {
            do {
                try await installVPNConfiguration()
                Task { @MainActor in
                    installingStatus = .succeeded
                    appRouter.navigate(to: successDestination)
                }
            } catch {
                errorMessage = errorMapper.map(error: error)
                
                Task { @MainActor in
                    shouldShowErrorMessage = true
                    installingStatus = .failed(errorMessage: errorMessage)
                }
            }
        }
    }
}
