//
//  VPNConfigurationAvailability.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

private extension String {
    static let kOnboardingVpnProfileInstalled = "kOnboardingVpnProfileInstalled"
}

class VPNConfigurationAvailability: VPNConfigurationAvailabilityType {
    private let userDefautls: UserDefaults
    
    init(userDefautls: UserDefaults = .standard) {
        self.userDefautls = userDefautls
    }
    
    func get() -> Bool {
        return userDefautls.bool(forKey: .kOnboardingVpnProfileInstalled)
    }
    
    func set(value: Bool) {
        userDefautls.set(value, forKey: .kOnboardingVpnProfileInstalled)
    }
}
