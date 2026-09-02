//
//  VPNConnectSpy.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

class VPNConnectSpy {

    private(set) var callAttempt = 0
    var error: Error?

    var wasCalled: Bool {
        callAttempt > 0
    }

    func connect(_ completion: @escaping (Error?) -> Void) {
        callAttempt += 1
        completion(error)
    }
}
