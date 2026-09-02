//
//  LegacyVPNProfilesType.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol LegacyVPNProfilesType {
    func isVPNConnected(_ completion: @escaping (Bool) -> Void)
    func removeAll(_ completion: @escaping (Bool) -> Void)
}
