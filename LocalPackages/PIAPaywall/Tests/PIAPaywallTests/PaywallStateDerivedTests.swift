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

import Foundation
import Testing

@testable import PIAPaywall

/// The copy on this screen quotes prices and promises a free trial, so what it says is worth
/// asserting on directly.
struct PaywallStateDerivedTests {

    // MARK: - Trial eligibility

    @Test("Each plan reports the trial its own App Store product carries")
    func trialIsReadFromEachOffer() {
        // GIVEN an eligible account where only the yearly product has an intro offer
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // THEN yearly offers the trial and monthly does not
        #expect(state.trialOffered(for: .yearly) == PaywallTrialOffer(days: 7))
        #expect(state.trialOffered(for: .monthly) == nil)
    }

    @Test("An ineligible account is offered no trial on any plan")
    func ineligibleAccountGetsNoTrial() {
        // GIVEN an account the App Store says is not eligible
        let state = Stub.readyState(isEligibleForIntroOffer: false)

        // THEN no plan offers a trial
        #expect(state.trialOffered(for: .yearly) == nil)
        #expect(state.trialOffered(for: .monthly) == nil)
    }

    @Test("A monthly intro offer is sold in the sheet like the yearly one")
    func monthlyTrialIsSoldInTheSheet() throws {
        // GIVEN a monthly product that carries its own 3-day intro offer
        let monthly = Stub.offer(
            .monthly,
            price: "$16.99",
            monthly: "$16.99",
            monthlyPrice: Decimal(string: "16.99")!,
            trialDays: 3
        )
        var state = Stub.readyState(offers: [.yearly: Stub.yearly, .monthly: monthly])

        // WHEN monthly is picked in the sheet
        state.sheetSelection = .monthly

        // THEN the sheet sells monthly's own trial, with its own length
        #expect(state.trialOffered(for: .monthly) == PaywallTrialOffer(days: 3))
        #expect(state.sheetButtonTitle == "Start My 3-day Free Trial")
        let disclaimer = try #require(state.sheetDisclaimer)
        #expect(disclaimer.headline == "Free for 3 days, then $16.99/month. Cancel anytime.")
        #expect(state.trialFooter(for: .monthly) == "Try FREE for 3 Days")

        // AND the main screen keeps selling yearly's trial
        #expect(state.primaryButtonTitle == "Start My 7-day Free Trial")
    }

    // MARK: - Call to action

    @Test("The sheet sells monthly at the monthly price even when a trial is available")
    func sheetButtonTitleFollowsItsOwnSelection() {
        // GIVEN an eligible account with monthly picked in the sheet
        var state = Stub.readyState(isEligibleForIntroOffer: true)
        state.sheetSelection = .monthly

        // THEN the sheet's button sells monthly at its price, because the monthly product has no
        // intro offer
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

    @Test(
        "Each card leads with the per-month price and explains how it is billed",
        arguments: [
            (PaywallPlanID.yearly, "$6.08/month", "$72.98 billed once a year"),
            (PaywallPlanID.monthly, "$16.99/month", "Billed monthly")
        ]
    )
    func planCardPrices(plan: PaywallPlanID, price: String, detail: String) throws {
        // GIVEN a loaded paywall
        let state = Stub.readyState()

        // THEN each card shows the per-month price and its billing detail
        let offer = try #require(state.offers[plan])
        #expect(state.cardPrice(for: offer) == price)
        #expect(state.cardBillingDetail(for: offer) == detail)
    }

    @Test("Yearly shows its saving against monthly, rounded to a whole percent")
    func yearlyShowsItsSaving() {
        // GIVEN $47.99/year against $11.99/month, a 66.6% saving
        let yearly = Stub.offer(.yearly, price: "$47.99", monthly: "$4.00", monthlyPrice: Decimal(string: "47.99")! / 12)
        let monthly = Stub.offer(.monthly, price: "$11.99", monthly: "$11.99", monthlyPrice: Decimal(string: "11.99")!)
        let state = Stub.readyState(offers: [.yearly: yearly, .monthly: monthly])

        // THEN yearly is tagged with the rounded saving and monthly carries no tag
        let locale = Locale(identifier: "en_US")
        #expect(state.savingsTitle(for: .yearly, locale: locale) == "Save 67%")
        #expect(state.savingsTitle(for: .monthly, locale: locale) == nil)
    }

    @Test("No saving is claimed without a monthly plan to compare against")
    func noSavingWithoutMonthly() {
        // GIVEN only yearly on sale
        let state = Stub.readyState(offers: [.yearly: Stub.yearly])

        // THEN there is nothing to compare, so no tag
        #expect(state.savingsTitle(for: .yearly, locale: Locale(identifier: "en_US")) == nil)
    }

    @Test("No saving is claimed when yearly is not cheaper per month")
    func noSavingWhenYearlyIsNotCheaper() {
        // GIVEN a yearly plan that costs the same per month as monthly
        let yearly = Stub.offer(.yearly, price: "$120.00", monthly: "$10.00", monthlyPrice: 10)
        let monthly = Stub.offer(.monthly, price: "$10.00", monthly: "$10.00", monthlyPrice: 10)
        let state = Stub.readyState(offers: [.yearly: yearly, .monthly: monthly])

        // THEN no saving is claimed
        #expect(state.savingsTitle(for: .yearly, locale: Locale(identifier: "en_US")) == nil)
    }

    @Test("The trial footer follows each plan's own trial length")
    func trialFooterUsesTheOfferedDays() {
        // GIVEN a yearly product with a 14-day intro offer
        let yearly = Stub.offer(.yearly, trialDays: 14)
        let state = Stub.readyState(offers: [.yearly: yearly, .monthly: Stub.monthly])

        // THEN yearly promises 14 days and monthly says it has no trial
        #expect(state.trialFooter(for: .yearly) == "Try FREE for 14 Days")
        #expect(state.trialFooter(for: .monthly) == "No free trial on this plan")
    }

    @Test("Without any trial every card says so")
    func everyCardSaysNoTrialWhenIneligible() {
        // GIVEN an ineligible account
        let state = Stub.readyState(isEligibleForIntroOffer: false)

        // THEN both cards say there is no trial
        #expect(state.trialFooter(for: .yearly) == "No free trial on this plan")
        #expect(state.trialFooter(for: .monthly) == "No free trial on this plan")
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
