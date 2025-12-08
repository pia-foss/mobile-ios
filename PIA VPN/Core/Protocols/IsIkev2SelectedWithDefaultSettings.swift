//
//  IsIkev2SelectedWithDefaultSettings.swift
//  PIA VPN
//
//  Created by Juan Docal on 2024-02-05.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class IsIkev2SelectedWithDefaultSettings {

    private let DEFAULT_IKEV2_ENCRYPTION = "aes-256-gcm"
    private let DEFAULT_IKEV2_HANDSHAKE = "sha256"
    private let DEFAULT_IKEV2_MTU = 0

    private let preferences: Client.Preferences

    init(preferences: Client.Preferences) {
        self.preferences = preferences
    }

    func callAsFunction() -> Bool {
        return preferences.vpnType == IKEv2Profile.vpnType &&
        preferences.ikeV2EncryptionAlgorithm.lowercased() == DEFAULT_IKEV2_ENCRYPTION &&
        preferences.ikeV2IntegrityAlgorithm.lowercased() == DEFAULT_IKEV2_HANDSHAKE &&
        preferences.ikeV2PacketSize == DEFAULT_IKEV2_MTU
    }
}
