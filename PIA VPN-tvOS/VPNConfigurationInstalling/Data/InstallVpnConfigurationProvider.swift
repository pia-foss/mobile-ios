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
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
  
    
    func callAsFunction() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            if isSimulator {
                NSLog(">>> >>> Simulator")
                continuation.resume()
                vpnConfigurationAvailability.set(value: true)
            } else {
                vpnProvider.install(force: true) { [self] error in
                    if error != nil {
                        continuation.resume(throwing: InstallVPNConfigurationError.userCanceled)
                        return
                    }
                    
                    continuation.resume()
                    vpnConfigurationAvailability.set(value: true)
                }
            }
            

        }
    }
}
