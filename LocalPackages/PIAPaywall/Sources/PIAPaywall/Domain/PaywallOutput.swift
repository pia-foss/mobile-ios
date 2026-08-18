//
//  PaywallOutput.swift
//  PIAPaywall
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

import PIALibrary

extension Paywall {

    /// Everything the paywall asks its host to do.
    ///
    /// The paywall knows nothing about navigation, storyboards or toast banners — it only reports what
    /// happened. The host (a coordinator in the app target) decides what that means. This is the
    /// "a screen should never know what comes next" rule from ADR 0006.
    ///
    /// These leave through `Paywall.Dependencies.emit` rather than through `Paywall.State`, because
    /// `UserAccount` and `InAppTransaction` are neither `Equatable` nor `Sendable`, and the state has to
    /// stay both.
    public enum Output {
        /// A subscription was purchased. The host starts account creation with this transaction.
        case didPurchase(transaction: any InAppTransaction)

        /// A restore found an existing subscription and signed the customer in.
        case didAuthenticate(user: UserAccount)

        /// The customer wants to sign in to an existing account.
        case requestLogin

        /// A transient message to show in the host's banner. Already localized.
        case showWarning(message: String)
    }
}
