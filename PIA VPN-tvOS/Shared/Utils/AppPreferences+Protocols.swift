//
//  AppPreferences+Protocols.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol AppPreferencesType {
    func reset()
}

extension AppPreferences: AppPreferencesType {
}
