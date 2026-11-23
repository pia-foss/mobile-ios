//
//  AccountDetails.swift
//  PIAAccountDetails
//
//  Copyright © 2026 Private Internet Access, Inc.
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

public enum AccountDetails {}

extension AccountDetails {

    /// The logged-in account, reduced to what the screen shows.
    public struct Account: Equatable, Sendable {
        public enum Expiry: Equatable, Sendable {
            case expired
            /// The date is already formatted for display.
            case expires(on: String)
        }

        public var username: String
        public var expiry: Expiry
        /// Whether the App Store subscription sheet can be opened for this plan.
        public var canManageSubscription: Bool
        /// Whether an uncredited purchase can be restored to renew the plan.
        public var isRenewable: Bool

        public init(username: String, expiry: Expiry, canManageSubscription: Bool, isRenewable: Bool) {
            self.username = username
            self.expiry = expiry
            self.canManageSubscription = canManageSubscription
            self.isRenewable = isRenewable
        }
    }

    public enum Alert: Hashable, Identifiable, Sendable {
        case restoreSucceeded
        /// The receipt had no purchase that could renew the plan.
        case noRedeemablePurchase
        case failure(message: String)

        public var id: Self { self }
    }

    /// How restoring an uncredited purchase ended.
    public enum RestoreResult: Equatable, Sendable {
        case renewed
        case badReceipt
        case failed(message: String)
    }

    public struct State: Equatable {
        public var account: Account?
        public var isRestoring: Bool
        public var alert: Alert?

        public init(account: Account?, isRestoring: Bool = false, alert: Alert? = nil) {
            self.account = account
            self.isRestoring = isRestoring
            self.alert = alert
        }
    }

    public enum Action: Equatable {
        case onAppear
        case accountUpdated(Account?)
        case restoreTapped
        case restoreFinished(RestoreResult)
        case alertDismissed
        case manageSubscriptionTapped
        case deleteAccountTapped
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        /// Open the App Store subscription management sheet.
        case manageSubscription
        /// Open the delete account help page.
        case deleteAccount
    }

    public struct Dependencies: Sendable {
        public var currentAccount: @MainActor () -> Account?
        /// Asks the backend for fresh account info; `accountUpdates` reports when it lands.
        public var refreshAccount: @MainActor () -> Void
        public var accountUpdates: @MainActor () -> AsyncStream<Void>
        public var restorePurchase: @MainActor () async -> RestoreResult
        public var emit: @MainActor (Output) -> Void

        public init(
            currentAccount: @MainActor @escaping () -> Account?,
            refreshAccount: @MainActor @escaping () -> Void,
            accountUpdates: @MainActor @escaping () -> AsyncStream<Void>,
            restorePurchase: @MainActor @escaping () async -> RestoreResult,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.currentAccount = currentAccount
            self.refreshAccount = refreshAccount
            self.accountUpdates = accountUpdates
            self.restorePurchase = restorePurchase
            self.emit = emit
        }
    }
}
