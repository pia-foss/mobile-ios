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
