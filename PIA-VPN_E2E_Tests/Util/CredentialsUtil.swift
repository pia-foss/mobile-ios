//
//  CredentialsUtil.swift
//  PIA VPN
//
//  Created by Waleed Mahmood on 08.03.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
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
            return Credentials(username: "fakeUser", password: "fakePassword123")
        case .valid:
            let testUser = ProcessInfo.processInfo.environment["PIA_TEST_USER"] ?? "user-not-found"
            let testPassword = ProcessInfo.processInfo.environment["PIA_TEST_PASSWORD"] ?? "password-not-found"
            return Credentials(username: testUser, password: testPassword)
        }
    }
}
