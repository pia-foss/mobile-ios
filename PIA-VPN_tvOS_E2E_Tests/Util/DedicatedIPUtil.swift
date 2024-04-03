//
//  DedicatedIPUtil.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 27/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

public enum DedicatedIPType: String {
    case valid = "valid"
    case invalid = "invalid"
    case empty = "empty"
}

public struct DedicatedIP: Codable {
    let token: String
}

public class DedicatedIPUtil {
    public static func dedicatedIP(type: DedicatedIPType) -> DedicatedIP {
        switch type {
        case .empty:
            return DedicatedIP(token: "")
        case .invalid:
            return DedicatedIP(token: "aaa")
        case .valid:
            let testDedicatedIP = ProcessInfo.processInfo.environment["PIA_TEST_DEDICATEDIP"] ?? "dedicated ip not found"
            return DedicatedIP(token: testDedicatedIP)
        }
    }
}
