//
//  PaywallStateDerivedTests.swift
//  PIAPaywallTests
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

import Testing

@testable import PIAPaywall

/// The copy on this screen quotes prices and promises a free trial, so what it says is worth
/// asserting on directly.
struct PaywallStateDerivedTests {

    // MARK: - Trial eligibility

    @Test("An eligible account is offered the trial on yearly only")
    func trialIsOfferedOnYearlyOnly() {
        // GIVEN an account the App Store says is eligible
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // THEN the trial is sold on yearly; monthly is always a straight subscription
        #expect(state.trialOffered(for: .yearly) == PaywallTrialOffer(days: 7))
        #expect(state.trialOffered(for: .monthly) == nil)
    }

    // MARK: - Call to action

    @Test("The sheet sells monthly at the monthly price even when a trial is available")
    func sheetButtonTitleFollowsItsOwnSelection() {
        // GIVEN an eligible account with monthly picked in the sheet
        var state = Stub.readyState(isEligibleForIntroOffer: true)
        state.sheetSelection = .monthly

        // THEN the sheet's button sells monthly even though the account could take a trial,
        // because the trial is only ever offered on the yearly plan
        #expect(state.sheetButtonTitle == "Subscribe • $16.99/mo")

        // AND the main screen is untouched
        #expect(state.primaryButtonTitle == "Start My 7-day Free Trial")
    }

    // MARK: - Disclaimer

    /// The trial line quotes the **billing period** price, not the per-month equivalent. Quoting
    /// "$6.08" where the customer will be charged "$72.98" would be a misrepresentation.
    @Test("The trial disclaimer quotes the yearly price, not the monthly equivalent")
    func trialDisclaimerQuotesTheYearlyPrice() throws {
        // GIVEN an eligible account
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // WHEN the disclaimer is rendered
        let disclaimer = try #require(state.disclaimer)

        // THEN it quotes the per-year price
        #expect(disclaimer.headline == "Free for 7 days, then $72.98/year. Cancel anytime.")
        #expect(
            disclaimer.detail
                == "You will be charged on the last day of your trial, unless you cancel before your free trial ends."
        )
    }

    @Test("A monthly selection gets recurring copy rather than trial copy")
    func monthlyDisclaimerUsesRecurringCopy() throws {
        // GIVEN monthly picked in the sheet
        var state = Stub.readyState(isEligibleForIntroOffer: true)
        state.sheetSelection = .monthly

        // WHEN the sheet's disclaimer is rendered
        let disclaimer = try #require(state.sheetDisclaimer)

        // THEN it describes a recurring subscription, not a trial
        #expect(disclaimer.headline == "$16.99 per month, billed monthly.")
        #expect(disclaimer.detail == "Renews automatically unless cancelled at least 24 hours before expiry date.")
    }

    @Test("An ineligible account on yearly gets the yearly recurring copy")
    func yearlyWithoutTrialUsesRecurringCopy() {
        // GIVEN an ineligible account on the yearly plan
        let state = Stub.readyState(isEligibleForIntroOffer: false)

        // THEN the yearly recurring copy is used
        #expect(state.disclaimer?.headline == "$72.98 per year, billed annually.")
    }

    /// Prices are formatted from the product's own locale, so a non-USD storefront must flow
    /// through unchanged rather than being reformatted or prefixed with "$".
    @Test("A non-USD storefront's price is passed through verbatim")
    func nonUSDPriceIsPassedThroughVerbatim() {
        // GIVEN a euro-priced yearly plan
        let euroOffer = Stub.offer(.yearly, price: "72,98 €", monthly: "6,08 €")
        let state = Stub.readyState(offers: [.yearly: euroOffer], isEligibleForIntroOffer: false)

        // THEN the euro formatting survives
        #expect(state.disclaimer?.headline == "72,98 € per year, billed annually.")
        #expect(state.primaryButtonTitle == "Subscribe • 6,08 €/mo")
    }

    // MARK: - Plan cards

    @Test("Only yearly carries a badge, and it names the trial when there is one")
    func yearlyCarriesTheTrialBadge() {
        // GIVEN an eligible account
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // THEN yearly is badged with the trial and monthly carries nothing
        #expect(state.badgeTitle(for: .yearly) == "Best Value – 7-day Free Trial")
        #expect(state.badgeTitle(for: .monthly) == nil)
    }

    @Test("Without a trial the yearly badge stops promising one")
    func yearlyKeepsThePlainBestValueBadge() {
        // GIVEN an ineligible account
        let state = Stub.readyState(isEligibleForIntroOffer: false)

        // THEN the badge no longer promises a trial
        #expect(state.badgeTitle(for: .yearly) == "Best Value")
    }

    @Test(
        "Each plan card shows its own billing period",
        arguments: [
            (PaywallPlanID.yearly, "$72.98/year", "Billed annually"),
            (PaywallPlanID.monthly, "$16.99/month", "Billed monthly")
        ]
    )
    func planCardsUseTheBillingPeriodSuffix(plan: PaywallPlanID, price: String, period: String) throws {
        // GIVEN a loaded paywall
        let state = Stub.readyState()

        // THEN each card shows its own billing period
        let offer = try #require(state.offers[plan])
        #expect(state.priceString(for: offer) == price)
        #expect(state.billingPeriodString(for: plan) == period)
    }

    // MARK: - Screen state

    @Test("While loading, no price is claimed and nothing can be bought — but restore still works")
    func skeletonBlocksPurchaseButNotRestore() {
        // GIVEN a paywall whose prices have not arrived
        let state = Paywall.State()

        // THEN price-bearing text renders redacted and nothing can be bought yet
        #expect(state.isSkeleton)
        #expect(state.canPurchase == false)
        #expect(state.disclaimer == nil)

        // AND restore still works, because it needs no products
        #expect(state.canRestore)
    }
}
