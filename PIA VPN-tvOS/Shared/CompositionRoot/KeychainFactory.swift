//
//  KeychainFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class KeychainFactory {
    static func makeKeychain() -> KeychainType {
        return Keychain(team: AppConstants.teamId, group: AppConstants.appGroup)
    }
}
