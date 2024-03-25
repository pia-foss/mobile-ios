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

extension PIALibrary.UserAccount {
    static func makeStub() -> PIALibrary.UserAccount {
        let credentials = PIALibrary.Credentials(username: "username",
                                                 password: "password")
        return PIALibrary.UserAccount(credentials: credentials,
                                      info: AccountInfo.makeStub())
    }
    
    static func makeExpiredStub() -> PIALibrary.UserAccount {
        let credentials = PIALibrary.Credentials(username: "username",
                                                 password: "password")
        return PIALibrary.UserAccount(credentials: credentials,
                                      info: AccountInfo.makeExpiredStub())
    }
}

extension PIALibrary.AccountInfo {
    static func makeStub() -> PIALibrary.AccountInfo {
        
        let account = AccountInformation(active: true,
                                         canInvite: true,
                                         canceled: true,
                                         daysRemaining: 0,
                                         email: "email",
                                         expirationTime: Int32(Date(timeIntervalSinceNow: 800).timeIntervalSince1970),
                                         expireAlert: false,
                                         expired: false,
                                         needsPayment: true,
                                         plan: "monthly",
                                         productId: "productId",
                                         recurring: true,
                                         renewUrl: "renewUrl",
                                         renewable: true,
                                         username: "username")
        
        return PIALibrary.AccountInfo(accountInformation: account)
    }
    
    static func makeExpiredStub() -> PIALibrary.AccountInfo {
        
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
        
        return PIALibrary.AccountInfo(accountInformation: account)
    }
}

extension UserAccount: Equatable {
    public static func == (lhs: PIALibrary.UserAccount, rhs: PIALibrary.UserAccount) -> Bool {
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
