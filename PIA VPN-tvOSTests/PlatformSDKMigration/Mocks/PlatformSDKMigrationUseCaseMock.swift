//
//  PlatformSDKMigrationUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

@testable import PIA_VPN_tvOS

class PlatformSDKMigrationUseCaseMock: PlatformSDKMigrationUseCaseType {

    var shouldUsePlatformSDKTunnel = true

    var shouldConfirmMigrationResult = false
    // When set, the completion is stashed in `pendingConfirmationCheck` instead of being called,
    // so a test can assert what the app does while the check is still in flight.
    var withholdsShouldConfirmMigrationAnswer = false
    private(set) var pendingConfirmationCheck: ((Bool) -> Void)?
    private(set) var shouldConfirmMigrationCalledAttempt = 0

    func shouldConfirmMigration(_ completion: @escaping (Bool) -> Void) {
        shouldConfirmMigrationCalledAttempt += 1

        guard !withholdsShouldConfirmMigrationAnswer else {
            pendingConfirmationCheck = completion
            return
        }

        completion(shouldConfirmMigrationResult)
    }

    private(set) var confirmMigrationCalledAttempt = 0

    func confirmMigration() {
        confirmMigrationCalledAttempt += 1
    }

    private(set) var cleanupLegacyVPNProfilesIfNeededCalledAttempt = 0

    func cleanupLegacyVPNProfilesIfNeeded() {
        cleanupLegacyVPNProfilesIfNeededCalledAttempt += 1
    }
}
