//
//  IsIkev2SelectedWithDefaultSettings.swift
//  PIA VPN
//
//  Created by Juan Docal on 2024-02-05.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

final class IsIkev2SelectedWithDefaultSettings {

    private let DEFAULT_IKEV2_ENCRYPTION: IKEv2EncryptionAlgorithm = .default
    private let DEFAULT_IKEV2_HANDSHAKE: IKEv2IntegrityAlgorithm = .default
    private let DEFAULT_IKEV2_MTU = 0

    private let preferences: Client.Preferences

    init(preferences: Client.Preferences) {
        self.preferences = preferences
    }

    func callAsFunction() -> Bool {
        return preferences.vpnType == IKEv2Profile.vpnType
            && preferences.ikeV2EncryptionAlgorithm == DEFAULT_IKEV2_ENCRYPTION
            && preferences.ikeV2IntegrityAlgorithm == DEFAULT_IKEV2_HANDSHAKE
            && preferences.ikeV2PacketSize == DEFAULT_IKEV2_MTU
    }
}
