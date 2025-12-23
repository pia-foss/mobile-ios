//
//  InstallVpnConfigurationProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class InstallVpnConfigurationProvider: InstallVPNConfigurationUseCaseType {
    private let vpnProvider: VpnConfigurationProviderType
    private let vpnConfigurationAvailability: VPNConfigurationAvailabilityType
    
    init(vpnProvider: VpnConfigurationProviderType, vpnConfigurationAvailability: VPNConfigurationAvailabilityType) {
        self.vpnProvider = vpnProvider
        self.vpnConfigurationAvailability = vpnConfigurationAvailability
    }
    
    func callAsFunction() async throws {
        do {
            try await vpnProvider.install(force: true)
            vpnConfigurationAvailability.set(value: true)
        } catch {
            throw InstallVPNConfigurationError.userCanceled
        }
    }
}
