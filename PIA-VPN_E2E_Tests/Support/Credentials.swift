//
//  Credentials.swift
//  PIA VPN
//
//  Created by Waleed Mahmood on 08.03.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation

/// Account credentials for signing in. The valid account is injected through the `PIA_TEST_USER` and
/// `PIA_TEST_PASSWORD` environment variables, never committed.
struct Credentials {
    let username: String
    let password: String

    static var valid: Credentials {
        let environment = ProcessInfo.processInfo.environment
        return Credentials(
            username: environment["PIA_TEST_USER"] ?? "user-not-found",
            password: environment["PIA_TEST_PASSWORD"] ?? "password-not-found"
        )
    }

    static let invalid = Credentials(username: "aaa", password: "Aaa123")
}
