//
//  AccountInfo.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

struct AccountInfo {
    let email: String?
    let username: String
    let plan: Plan
    let productId: String?
    let isRenewable: Bool
    let isRecurring: Bool
    let expirationDate: Date
    let canInvite: Bool
    
    public var isExpired: Bool {
        return (expirationDate.timeIntervalSinceNow < 0)
    }
    
    public var dateComponentsBeforeExpiration: DateComponents {
        return Calendar.current.dateComponents([.day, .hour], from: Date(), to: expirationDate)
    }
    
    public let shouldPresentExpirationAlert: Bool
    public let renewUrl: URL?
    
    public func humanReadableExpirationDate(usingLocale locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = locale
        return dateFormatter.string(from: self.expirationDate)
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
