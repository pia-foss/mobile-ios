//
//  VPNConfigurationAvailabilityType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol VPNConfigurationAvailabilityType {
    func get() -> Bool
    func set(value: Bool)
}
