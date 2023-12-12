//
//  Stubs.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

extension UserAccount {
    static func makeStub() -> UserAccount {
        let credentials = Credentials(username: "username",
                                      password: "password")
        return UserAccount(credentials: credentials,
                           info: AccountInfo.makeStub())
    }
}

extension AccountInfo {
    static func makeStub() -> AccountInfo {
        return AccountInfo(email: "email",
                           username: "username",
                           plan: Plan.monthly,
                           productId: "productId",
                           isRenewable: true,
                           isRecurring: true,
                           expirationDate: Date(),
                           canInvite: true,
                           shouldPresentExpirationAlert: true,
                           renewUrl: URL(string: "https://an-url.com"))
    }
}

extension UserAccount: Equatable {
    public static func == (lhs: UserAccount, rhs: UserAccount) -> Bool {
        lhs.credentials == rhs.credentials
        && lhs.info == rhs.info
    }
}

extension Credentials: Equatable {
    public static func == (lhs: Credentials, rhs: Credentials) -> Bool {
        lhs.username == rhs.username && lhs.password == rhs.password
    }
}

extension AccountInfo: Equatable {
    public static func == (lhs: AccountInfo, rhs: AccountInfo) -> Bool {
        lhs.email == rhs.email
        && lhs.username == rhs.username
        && lhs.plan == rhs.plan
        && lhs.productId == rhs.productId
        && lhs.isRenewable == rhs.isRenewable
        && lhs.isRecurring == rhs.isRecurring
        && lhs.expirationDate == rhs.expirationDate
        && lhs.canInvite == rhs.canInvite
        && lhs.isExpired == rhs.isExpired
        && lhs.shouldPresentExpirationAlert == rhs.shouldPresentExpirationAlert
        && lhs.renewUrl == rhs.renewUrl
    }
}
