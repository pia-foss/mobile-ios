//
//  PaywallOffer.swift
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

/// One purchasable plan, with its prices already formatted in the storefront's locale.
///
/// A value type on purpose: `PIALibrary.PurchasePlan` is an `NSObject` and `InAppProduct` is not
/// `Equatable` in a useful way, so neither can live in an `Equatable` state. Formatting happens once,
/// where the StoreKit product is still in scope, and the rest of the feature works with plain strings.
///
/// - Important: every price here is derived from `product.price` and `product.priceLocale`. Nothing
///   in this feature may hardcode a currency symbol or an amount — that is how a paywall ends up
///   showing dollars to a customer being billed in euros.
public struct PaywallOffer: Equatable, Sendable {
    public let id: PaywallPlanID

    /// The billing-period price, e.g. `"$72.98"`.
    public let priceString: String

    /// The same subscription expressed per month, e.g. `"$6.08"` for a yearly plan.
    public let monthlyPriceString: String

    /// A spelled-out price for VoiceOver, e.g. `"6.08 US dollars"`.
    public let accessibleMonthlyPriceString: String

    public init(
        id: PaywallPlanID,
        priceString: String,
        monthlyPriceString: String,
        accessibleMonthlyPriceString: String
    ) {
        self.id = id
        self.priceString = priceString
        self.monthlyPriceString = monthlyPriceString
        self.accessibleMonthlyPriceString = accessibleMonthlyPriceString
    }
}
