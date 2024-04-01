//
//  CredentialsUtil.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

public enum CredentialsType: String {
    case valid = "valid"
    case invalid = "invalid"
}

public struct Credentials: Codable {
    let username: String
    let password: String
}

public class CredentialsUtil {
    public static func credentials(type: CredentialsType) -> Credentials {
        switch type {
        case .invalid:
            return Credentials(username: "aaa", password: "Aaa")
        case .valid:
            let testUser = ProcessInfo.processInfo.environment["PIA_TEST_USER"] ?? "user-not-found"
            let testPassword = ProcessInfo.processInfo.environment["PIA_TEST_PASSWORD"] ?? "password-not-found"
            return Credentials(username: testUser, password: testPassword)
        }
    }
}
