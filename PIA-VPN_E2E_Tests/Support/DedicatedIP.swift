//
//  DedicatedIP.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

/// Dedicated IP tokens for activation. The valid token is injected through the `PIA_TEST_DEDICATEDIP` environment
/// variable, never committed.
struct DedicatedIP {
    let token: String

    static var valid: DedicatedIP {
        DedicatedIP(token: ProcessInfo.processInfo.environment["PIA_TEST_DEDICATEDIP"] ?? "dedicated ip not found")
    }

    static let invalid = DedicatedIP(token: "aaa")
    static let empty = DedicatedIP(token: "")
}
