//
//  VPNConfigurationInstallingViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 15/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: VPNConfigurationInstallingViewModel.self)

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

        log.info("VPN configuration install requested")
        installingStatus = .isInstalling

        Task {
            do {
                try await installVPNConfiguration()
                log.info("VPN configuration installed successfully")
                Task { @MainActor in
                    installingStatus = .succeeded
                    onSuccessAction()
                }
            } catch {
                log.error("VPN configuration install failed: \(error.localizedDescription)")
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
    var title: String { L10n.Onboarding.VpnConfiguration.title }
    var subtitle: String? { L10n.Onboarding.VpnConfiguration.subtitle }
    var buttons: [OnboardingComponentButton] {
        [OnboardingComponentButton(title: L10n.Onboarding.VpnConfiguration.button, action: { [weak self] in self?.install() })]
    }
}
