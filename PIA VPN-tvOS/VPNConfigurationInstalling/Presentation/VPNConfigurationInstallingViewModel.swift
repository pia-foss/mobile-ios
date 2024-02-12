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
    private let onSuccessAction: () -> Void
    
    @Published var shouldShowErrorMessage = false
    @Published var installingStatus: VPNConfigurationInstallingStatus = .none
    var errorMessage: String?
    
    init(installVPNConfiguration: InstallVPNConfigurationUseCaseType, errorMapper: VPNConfigurationInstallingErrorMapper, onSuccessAction: @escaping () -> Void) {
        self.installVPNConfiguration = installVPNConfiguration
        self.errorMapper = errorMapper
        self.onSuccessAction = onSuccessAction
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
                    onSuccessAction()
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

extension VPNConfigurationInstallingViewModel: OnboardingComponentViewModelType {
    var title: String { L10n.Localizable.Onboarding.VpnConfiguration.title }
    var subtitle: String? { L10n.Localizable.Onboarding.VpnConfiguration.subtitle }
    var buttons: [OnboardingComponentButton] {
        [OnboardingComponentButton(title: L10n.Localizable.Onboarding.VpnConfiguration.button, action: { [weak self] in self?.install() })]
    }
}
