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
    @Published var shouldShowErrorMessage = false
    @Published var didInstallVPNProfile = false
    @Published var installingStatus: VPNConfigurationInstallingStatus = .none
    var errorMessage: String?
    
    init(installVPNConfiguration: InstallVPNConfigurationUseCaseType, errorMapper: VPNConfigurationInstallingErrorMapper) {
        self.installVPNConfiguration = installVPNConfiguration
        self.errorMapper = errorMapper
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
                    didInstallVPNProfile = true
                    installingStatus = .succeeded
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
