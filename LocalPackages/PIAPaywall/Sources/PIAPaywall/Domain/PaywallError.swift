//
//  PaywallError.swift
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

import PIALocalizations

/// Everything that can go wrong on the paywall, reduced to the cases the UI treats differently.
///
/// `PIALibrary.ClientError` is deliberately *not* used here. Its `errorDescription` is `nil` for
/// every case except `.sandboxPurchase` and `.purchasePending`, so surfacing it produces
/// "The operation couldn't be completed. (PIALibrary.ClientError error 21.)" — and the extension
/// that localizes it lives in the app target, invisible to this package. Mapping happens once, in
/// `PaywallDependencies.live`, and the UI only ever sees a localized message.
public enum PaywallError: Error, Equatable, Sendable {
    /// The customer dismissed the App Store sheet. Not an error: show nothing at all.
    case userCancelled

    /// Awaiting external approval (Ask to Buy). The account is not created yet.
    case purchasePending

    /// No purchasable products came back, so there is nothing to sell.
    case productsUnavailable

    /// A restore found no receipt on this App Store account.
    case nothingToRestore

    /// A restore found a receipt, but signing in with it failed.
    case restoreLoginFailed

    /// Anything else, already localized.
    case failed(message: String)
}

extension PaywallError {
    /// The message to surface, or `nil` when the failure should be silent.
    var userFacingMessage: String? {
        switch self {
        case .userCancelled:
            return nil
        case .purchasePending:
            return L10n.Signup.Failure.Purchase.Pending.message
        case .productsUnavailable:
            return L10n.Signup.Paywall.Error.productsUnavailable
        case .nothingToRestore, .restoreLoginFailed:
            // Both are surfaced as alerts by the reducer, not as banners.
            return nil
        case .failed(let message):
            return message
        }
    }
}
