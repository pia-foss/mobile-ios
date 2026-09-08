//
//  AppPreferencesMock.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

@testable import PIA_VPN_tvOS

class AppPreferencesMock: AppPreferencesType {

    var didConfirmPlatformSDKMigration = false
    var didCleanupLegacyVPNProfiles = false

    private(set) var resetCalledAttempt = 0

    func reset() {
        resetCalledAttempt += 1
    }
}
