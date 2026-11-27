//
//  SideMenu.swift
//  PIASideMenu
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
import PIALibrary

public enum SideMenu {}

extension SideMenu {

    /// The logged-in account, reduced to what the menu shows.
    public struct Account: Equatable, Sendable {
        public var username: String
        /// Set when the App Store can manage the subscription, which the header then offers.
        public var managedPlan: Plan?
        /// Set when the account is about to expire, which shows the renewal banner.
        public var expiration: Expiration?

        public init(username: String, managedPlan: Plan? = nil, expiration: Expiration? = nil) {
            self.username = username
            self.managedPlan = managedPlan
            self.expiration = expiration
        }
    }

    public enum Expiration: Equatable, Sendable {
        case days(Int)
        case hours(Int)
        case underAnHour
    }

    public enum Item: Hashable, Sendable {
        case destination(Destination)
        case website(Website)
        case logout

        static let primary: [Item] = [
            .destination(.regionSelection), .destination(.account), .destination(.dedicatedIP),
            .destination(.settings), .logout
        ]
        static let secondary: [Item] = [
            .destination(.about), .website(.privacy), .website(.home), .website(.support)
        ]
    }

    /// Screens the host opens on top of the dashboard.
    public enum Destination: Hashable, Sendable {
        case regionSelection
        case account
        case dedicatedIP
        case settings
        case about
    }

    public enum Website: Hashable, Sendable {
        case home
        case support
        case privacy
    }

    public enum Alert: Equatable, Sendable {
        case logoutConfirmation
        /// Trials can't renew, only upgrade to a paid plan.
        case renewingTrial
        /// Only the website can renew this subscription.
        case renewingNonRenewable
        case renewalSucceeded
        case failure(message: String)
    }

    /// How renewing from the expiration banner ended.
    public enum RenewalResult: Equatable, Sendable {
        case renewed
        case cancelled
        case trial
        case nonRenewable
        case failed(message: String)
    }

    public struct State: Equatable {
        public var account: Account
        /// Renewing or logging out, which blocks the menu.
        public var isLoading: Bool
        public var alert: Alert?

        public init(account: Account, isLoading: Bool = false, alert: Alert? = nil) {
            self.account = account
            self.isLoading = isLoading
            self.alert = alert
        }
    }

    public enum Action: Equatable {
        case onAppear
        case accountUpdated(Account)
        case itemTapped(Item)
        case manageSubscriptionTapped
        case expirationTapped
        case renewalFinished(RenewalResult)
        case logoutConfirmed
        case logoutFinished
        case upgradeTrialConfirmed
        case renewOnWebsiteConfirmed
        case alertDismissed
    }

    /// Everything the menu asks its host to do.
    public enum Output: Equatable, Sendable {
        case show(Destination)
        case open(Website)
        case manageSubscription
        case upgradeTrial
    }

    public struct Dependencies: Sendable {
        public var currentAccount: @MainActor () -> Account
        /// Fires on login and on every account refresh.
        public var accountUpdates: @MainActor () -> AsyncStream<Void>
        public var renew: @MainActor () async -> RenewalResult
        public var logout: @MainActor () async -> Void
        public var emit: @MainActor (Output) -> Void

        public init(
            currentAccount: @MainActor @escaping () -> Account,
            accountUpdates: @MainActor @escaping () -> AsyncStream<Void>,
            renew: @MainActor @escaping () async -> RenewalResult,
            logout: @MainActor @escaping () async -> Void,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.currentAccount = currentAccount
            self.accountUpdates = accountUpdates
            self.renew = renew
            self.logout = logout
            self.emit = emit
        }
    }
}
