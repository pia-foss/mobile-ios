//
//  Stubs.swift
//  PIA VPNTests
//
//  Created for iOS tests.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIAAccount
#if os(iOS)
@testable import PIA_VPN

extension UserAccount {
    static func makeStub() -> UserAccount {
        let credentials = Credentials(
            username: "username",
            password: "password"
        )

        return UserAccount(
            credentials: credentials,
            info: AccountInfo.makeStub()
        )
    }

    static func makeExpiredStub() -> UserAccount {
        let credentials = Credentials(
            username: "username",
            password: "password"
        )

        return UserAccount(
            credentials: credentials,
            info: AccountInfo.makeExpiredStub()
        )
    }
}

extension AccountInfo {
    static func makeStub() -> AccountInfo {
        let account = AccountInformation(
            active: true,
            canInvite: true,
            canceled: true,
            daysRemaining: 0,
            email: "email",
            expirationTime: Int(Date(timeIntervalSinceNow: 800).timeIntervalSince1970),
            expireAlert: false,
            expired: false,
            needsPayment: true,
            plan: "monthly",
            productId: "productId",
            recurring: true,
            renewUrl: "renewUrl",
            renewable: true,
            username: "username"
        )

        return AccountInfo(accountInformation: account)
    }

    static func makeExpiredStub() -> AccountInfo {
        let account = AccountInformation(
            active: true,
            canInvite: true,
            canceled: true,
            daysRemaining: 0,
            email: "email",
            expirationTime: 0,
            expireAlert: true,
            expired: true,
            needsPayment: true,
            plan: "monthly",
            productId: "productId",
            recurring: true,
            renewUrl: "renewUrl",
            renewable: true,
            username: "username"
        )

        return AccountInfo(accountInformation: account)
    }
}
#endif
