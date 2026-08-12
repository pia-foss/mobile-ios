//
//  PaywallState+Derived.swift
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
import PIALocalizations

/// The two-part legal copy under the plan.
public struct PaywallDisclaimer: Equatable {
    /// Emphasised first sentence, carrying the price.
    public let headline: String
    /// The rest, in regular weight.
    public let detail: String
}

// Everything here is computed. Nothing derived is ever stored in `PaywallState`, so there is no way
// for a title and the price it quotes to drift apart.
public extension PaywallState {

    // MARK: Offers

    var yearlyOffer: PaywallOffer? { offers[.yearly] }
    var monthlyOffer: PaywallOffer? { offers[.monthly] }

    /// The plan the main screen's call to action buys.
    var defaultOffer: PaywallOffer? { offers[defaultPlan] }

    /// The plan the sheet's call to action buys.
    var sheetOffer: PaywallOffer? { offers[sheetSelection] }

    /// Trial offered for `plan`, if any.
    func trialOffered(for plan: PaywallPlanID) -> PaywallTrialOffer? {
        guard plan == .yearly else { return nil }
        return trialOffer
    }

    // MARK: Screen state

    /// Prices are still loading, so any price-bearing text must render redacted.
    var isSkeleton: Bool { phase == .loadingProducts }

    var isPurchasing: Bool { activity == .purchasing }
    var isRestoring: Bool { activity == .restoring }

    /// The purchase buttons only work once there is something to sell and nothing else is running.
    var canPurchase: Bool { phase == .ready && activity == .idle }

    /// Restore needs no products, so it stays available even when the catalogue failed to load.
    var canRestore: Bool { activity == .idle }

    /// A one-row sheet is worse than no sheet, so the entry point only appears with a real choice.
    var showsOtherPlansButton: Bool { offers.count > 1 }

    // MARK: Copy

    /// The main screen's call to action.
    var primaryButtonTitle: String { buttonTitle(for: defaultPlan) }

    /// The sheet's call to action, which follows the sheet's own selection.
    var sheetButtonTitle: String { buttonTitle(for: sheetSelection) }

    var disclaimer: PaywallDisclaimer? { disclaimer(for: defaultPlan) }

    var sheetDisclaimer: PaywallDisclaimer? { disclaimer(for: sheetSelection) }

    func buttonTitle(for plan: PaywallPlanID) -> String {
        if let introOffer = trialOffered(for: plan) {
            // Show "free trial" copy
            return L10n.Signup.Paywall.Cta.startTrial(introOffer.days)
        }
        guard let offer = offers[plan] else {
            // Only reachable in the skeleton state, where the label is redacted anyway.
            return L10n.Signup.Paywall.Cta.subscribe("--")
        }
        return L10n.Signup.Paywall.Cta.subscribe(L10n.Welcome.Plan.priceFormat(offer.monthlyPriceString))
    }

    func disclaimer(for plan: PaywallPlanID) -> PaywallDisclaimer? {
        guard let offer = offers[plan] else { return nil }

        if let introOffer = trialOffered(for: plan) {
            return PaywallDisclaimer(
                headline: L10n.Signup.Paywall.Disclaimer.Trial.headline(introOffer.days, priceString(for: offer)),
                detail: L10n.Signup.Paywall.Disclaimer.Trial.detail
            )
        }

        switch plan {
        case .yearly:
            return PaywallDisclaimer(
                headline: L10n.Signup.Paywall.Disclaimer.Yearly.headline(offer.priceString),
                detail: L10n.Signup.Paywall.Disclaimer.Renewal.detail
            )
        case .monthly:
            return PaywallDisclaimer(
                headline: L10n.Signup.Paywall.Disclaimer.Monthly.headline(offer.priceString),
                detail: L10n.Signup.Paywall.Disclaimer.Renewal.detail
            )
        }
    }

    // MARK: Plan cards

    func planTitle(for plan: PaywallPlanID) -> String {
        switch plan {
        case .yearly: return L10n.Welcome.Plan.Yearly.title
        case .monthly: return L10n.Welcome.Plan.Monthly.title
        }
    }

    /// The headline price on a plan card, e.g. `"$72.98/year"`.
    func priceString(for offer: PaywallOffer) -> String {
        switch offer.id {
        case .yearly: return L10n.Signup.Paywall.Plans.Price.yearly(offer.priceString)
        case .monthly: return L10n.Signup.Paywall.Plans.Price.monthly(offer.priceString)
        }
    }

    func billingPeriodString(for plan: PaywallPlanID) -> String {
        switch plan {
        case .yearly: return L10n.Signup.Paywall.Plans.Billing.yearly
        case .monthly: return L10n.Signup.Paywall.Plans.Billing.monthly
        }
    }

    /// The badge on a plan card, or `nil` when it carries none.
    func badgeTitle(for plan: PaywallPlanID) -> String? {
        guard plan == .yearly else { return nil }
        if let introOffer = trialOffered(for: plan) {
            return L10n.Signup.Paywall.Plans.Badge.bestValueTrial(introOffer.days)
        }
        return L10n.Signup.Paywall.Plans.Badge.bestValue
    }
}
