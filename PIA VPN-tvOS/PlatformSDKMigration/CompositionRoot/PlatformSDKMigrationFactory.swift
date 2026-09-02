//
//  PlatformSDKMigrationFactory.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import SwiftUI

enum PlatformSDKMigrationFactory {
    static let makePlatformSDKMigrationUseCase: PlatformSDKMigrationUseCaseType = {
        PlatformSDKMigrationUseCase(
            legacyVPNProfiles: LegacyVPNProfiles(),
            appPreferences: AppPreferences.shared,
            accountProvider: SettingsFactory.makeDefaultAccountProvider(),
            connectVPN: { completion in Client.providers.vpnProvider.connect(completion) }
        )
    }()

    static func makePlatformSDKMigrationView(onConfirm: @escaping () -> Void) -> PlatformSDKMigrationView {
        PlatformSDKMigrationView(onConfirm: onConfirm)
    }
}
