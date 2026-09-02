//
//  AppPreferences+Protocols.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol AppPreferencesType: AnyObject {
    func reset()

    /// Whether the user confirmed the migration to the PlatformSDK tunnel. Migrating disconnects
    /// a live tunnel, so bootstrap waits behind a confirmation notice until this is set.
    var didConfirmPlatformSDKMigration: Bool { get set }

    /// Whether the legacy IKEv2 configuration has been removed after migrating to the PlatformSDK
    /// tunnel. Runs once so a stale Network Extension config cannot auto-start via on-demand.
    var didCleanupLegacyVPNProfiles: Bool { get set }
}

extension AppPreferences: AppPreferencesType {}
