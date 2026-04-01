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
@testable import PIA_VPN_tvOS

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

extension InAppProductMock {
    static func makeStubs() -> [Plan: InAppProductMock] {
        [
            Plan.monthly : InAppProductMock(identifier: "001",
                                            price: 10.99,
                                            priceLocale: .current,
                                            native: nil,
                                            description: "monthly"),
            Plan.yearly : InAppProductMock(identifier: "002",
                                           price: 100.99,
                                           priceLocale: .current,
                                           native: nil,
                                           description: "yearly")
        ]
    }
}

extension SubscriptionProduct {
    static func makeStubs() -> [SubscriptionProduct] {
        [
            SubscriptionProduct(product: InAppProductMock(identifier: "001",
                                                          price: 10.99,
                                                          priceLocale: .current,
                                                          native: nil,
                                                          description: "monthly"),
                                type: .monthly),
            SubscriptionProduct(product: InAppProductMock(identifier: "002",
                                                          price: 100.99,
                                                          priceLocale: .current,
                                                          native: nil,
                                                          description: "yearly"),
                                type: .yearly)
        ]
    }
}

extension PIA_VPN_tvOS.Product {
    static func makeStubs() -> [PIA_VPN_tvOS.Product] {
        [
            PIA_VPN_tvOS.Product(identifier: "001", plan: .monthly, price: "10.99", legacy: false),
            PIA_VPN_tvOS.Product(identifier: "002", plan: .yearly, price: "100.99", legacy: false),
            PIA_VPN_tvOS.Product(identifier: "003", plan: .yearly, price: "87.99", legacy: true)
        ]
    }
}

extension InAppTransactionMock {
    static func makeStub() -> InAppTransactionMock {
        InAppTransactionMock(identifier: "001",
                             native: nil,
                             description: "description")
    }
}

extension PIALibrary.UserAccount: Equatable {
    public static func == (lhs: PIALibrary.UserAccount, rhs: PIALibrary.UserAccount) -> Bool {
        lhs.credentials == rhs.credentials
        && lhs.info == rhs.info
    }
}

extension PIALibrary.Credentials: Equatable {
    public static func == (lhs: PIALibrary.Credentials, rhs: PIALibrary.Credentials) -> Bool {
        lhs.username == rhs.username && lhs.password == rhs.password
    }
}

extension PIALibrary.AccountInfo: Equatable {
    public static func == (lhs: PIALibrary.AccountInfo, rhs: PIALibrary.AccountInfo) -> Bool {
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
