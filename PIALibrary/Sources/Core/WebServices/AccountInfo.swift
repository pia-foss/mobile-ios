//
//  AccountInfo.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/1/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

/// The information associated with a `Credentials`.
public struct AccountInfo {

    /// The linked email address if any.
    public internal(set) var email: String?
    
    /// PIA username
    public let username: String

    /// The currently subscribed `Plan`.
    public let plan: Plan
    
    /// The product id for the current subscription
    public let productId: String?
    
    /// Returns `true` if the account is eligible for renewal.
    ///
    /// - Seealso: `AccountProvider.renew(...)`
    public let isRenewable: Bool
    
    /// Returns `true` if the subscription is recurring (auto-renewable).
    public let isRecurring: Bool
    
    /// The date by when the account is due to expire.
    public let expirationDate: Date
    
    /// Returns `true` if the account can refer friends and get extra days
    public let canInvite: Bool
    
    /// Returns `true` if the account has expired.
    public var isExpired: Bool {
        return (expirationDate.timeIntervalSinceNow < 0)
    }
    
    /// Returns the `DateComponents` before `expirationDate`.
    public var dateComponentsBeforeExpiration: DateComponents {
        return Calendar.current.dateComponents([.day, .hour], from: Date(), to: expirationDate)
    }
    
    /**
     Returns `true` if the account is about to expire. The consumer should present
     an expiration alert and provide the user with a way to renew his account.
     */
    public let shouldPresentExpirationAlert: Bool

    /// Returns the URL to which a non-renewable subscription should be redirected.
    public let renewUrl: URL?
    
    func with(email: String) -> AccountInfo {
        var newInfo = self // copied (struct)
        newInfo.email = email
        return newInfo
    }
    
    /// Return the Human Readable Date for the expirationDate var.
    /// - Parameters:
    /// locale: The locale to format the date, by default will use the locale of the device
    public func humanReadableExpirationDate(usingLocale locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = locale
        return dateFormatter.string(from: self.expirationDate)
    }
}
