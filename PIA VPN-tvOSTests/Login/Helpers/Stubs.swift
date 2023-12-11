//
//  Stubs.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import account

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
        let account = AccountInformation(active: true,
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
                                         username: "username")
        
        return AccountInfo(accountInformation: account)
    }
}
