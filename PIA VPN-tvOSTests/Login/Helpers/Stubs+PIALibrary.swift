//
//  Stubs.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIAAccount
@testable import PIA_VPN_tvOS

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

extension InAppProductMock {
    static func makeStubs() -> [Plan: InAppProductMock] {
        [
            Plan.monthly : InAppProductMock(
                identifier: "001",
                price: 10.99,
                priceLocale: .current,
                native: nil,
                description: "monthly"
            ),
            Plan.yearly : InAppProductMock(
                identifier: "002",
                price: 100.99,
                priceLocale: .current,
                native: nil,
                description: "yearly"
            )
        ]
    }
}

extension SubscriptionProduct {
    static func makeStubs() -> [SubscriptionProduct] {
        [
            SubscriptionProduct(
                product: InAppProductMock(
                    identifier: "001",
                    price: 10.99,
                    priceLocale: .current,
                    native: nil,
                    description: "monthly"
                ),
                type: .monthly
            ),
            SubscriptionProduct(
                product: InAppProductMock(
                    identifier: "002",
                    price: 100.99,
                    priceLocale: .current,
                    native: nil,
                    description: "yearly"
                ),
                type: .yearly
            )
        ]
    }
}

extension Product {
    static func makeStubs() -> [Product] {
        [
            Product(identifier: "001", plan: .monthly, price: "10.99", legacy: false),
            Product(identifier: "002", plan: .yearly, price: "100.99", legacy: false),
            Product(identifier: "003", plan: .yearly, price: "87.99", legacy: true)
        ]
    }
}

extension InAppTransactionMock {
    static func makeStub() -> InAppTransactionMock {
        InAppTransactionMock(
            identifier: "001",
            native: nil,
            description: "description"
        )
    }
}
