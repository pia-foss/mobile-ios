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
        return try await withCheckedThrowingContinuation { continuation in
            vpnProvider.install(force: true) { [self] error in
                if error != nil {
                    continuation.resume(throwing: InstallVPNConfigurationError.userCanceled)
                    return
                }
                
                vpnConfigurationAvailability.set(value: true)
                continuation.resume()
            }
        }
    }
}
