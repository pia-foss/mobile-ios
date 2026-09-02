//
//  LegacyVPNProfilesMock.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

@testable import PIA_VPN_tvOS

final class LegacyVPNProfilesMock: LegacyVPNProfilesType, @unchecked Sendable {

    var isVPNConnectedResult = false
    // When set, the completion is stashed instead of called, so a test can drive the timeout.
    var withholdsIsVPNConnectedAnswer = false
    private(set) var pendingIsVPNConnectedAnswer: ((Bool) -> Void)?
    private(set) var isVPNConnectedCalledAttempt = 0

    func isVPNConnected(_ completion: @escaping (Bool) -> Void) {
        isVPNConnectedCalledAttempt += 1

        guard !withholdsIsVPNConnectedAnswer else {
            pendingIsVPNConnectedAnswer = completion
            return
        }

        completion(isVPNConnectedResult)
    }

    var removeAllResult = true
    private(set) var removeAllCalledAttempt = 0

    func removeAll(_ completion: @escaping (Bool) -> Void) {
        removeAllCalledAttempt += 1
        completion(removeAllResult)
    }
}
