//
//  SetWireguardMigrationPerformed.swift
//  PIA VPN
//
//  Created by Juan Docal on 2024-02-05.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SetWireguardMigrationPerformed {

    private let preferences: Client.Preferences

    init(preferences: Client.Preferences) {
        self.preferences = preferences
    }

    func callAsFunction() {
        preferences.wireguardMigrationPerformed = true
    }
}
