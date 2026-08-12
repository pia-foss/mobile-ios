//
//  PaywallEffect.swift
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

import Foundation
import PIALibrary

/// Work the reducer asks the store to perform.
///
/// Effects are **data, not closures**, which is the one place this design deliberately parts company
/// with TCA. Because `PaywallEffect` is `Equatable`, a reducer test is a synchronous value
/// comparison — `#expect(effect == .checkEntitlementThenPurchase(.yearly))` — with no awaiting, no
/// expectations and no test clock. Only `PaywallStore` knows how to actually run them.
public enum PaywallEffect: Equatable {
    case none
    case observePurchaseIntents
    case loadOffers

    /// The entitlement check must happen *before* the purchase: an App Store account that already
    /// owns a subscription is offered a restore instead of being charged twice.
    case checkEntitlementThenPurchase(PurchaseRequest)

    case restore

    /// Finish the transaction the store is holding, so the App Store stops redelivering it.
    case finishPendingTransaction

    case emit(PaywallOutputSignal)

    indirect case batch([PaywallEffect])
}

/// An output the reducer wants emitted.
///
/// Separate from `PaywallOutput` because the reducer cannot see the transaction or user account
/// those cases carry — the store substitutes them when it interprets the effect. Keeping this type
/// `Equatable` is what lets the reducer tests assert on emitted outputs.
public enum PaywallOutputSignal: Equatable {
    case didPurchase
    case didAuthenticate
    case requestLogin
    case didCancel
    case showWarning(message: String)
}
