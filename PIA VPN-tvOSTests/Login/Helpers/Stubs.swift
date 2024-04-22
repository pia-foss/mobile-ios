//
//  Stubs.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

extension PIA_VPN_tvOS.UserAccount {
    static func makeStub() -> PIA_VPN_tvOS.UserAccount {
        let credentials = PIA_VPN_tvOS.Credentials(username: "username",
                                                   password: "password")
        return UserAccount(credentials: credentials,
                           info: AccountInfo.makeStub())
    }
}

extension PIA_VPN_tvOS.AccountInfo {
    static func makeStub() -> PIA_VPN_tvOS.AccountInfo {
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
