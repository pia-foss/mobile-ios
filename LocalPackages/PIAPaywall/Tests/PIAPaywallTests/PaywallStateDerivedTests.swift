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

import XCTest

@testable import PIAPaywall

/// The copy on this screen quotes prices and promises a free trial, so what it says is worth
/// asserting on directly.
final class PaywallStateDerivedTests: XCTestCase {

    // MARK: - Trial eligibility

    func test_trial_WHEN_eligible_THEN_offeredOnYearlyOnly() {
        // GIVEN an account the App Store says is eligible
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // THEN the trial is sold on yearly; monthly is always a straight subscription
        XCTAssertTrue(state.isTrialOffered(for: .yearly))
        XCTAssertFalse(state.isTrialOffered(for: .monthly))
    }

    func test_trial_WHEN_notEligible_THEN_timelineIsHiddenAndCtaSells() {
        // GIVEN an account that already used its trial
        let state = Stub.readyState(isEligibleForIntroOffer: false)

        // THEN the "How your free trial works" card is hidden, because it would be untrue
        XCTAssertFalse(state.showsTrialTimeline)

        // AND the call to action sells the subscription instead
        XCTAssertEqual(state.primaryButtonTitle, "Subscribe • $6.08/mo")
    }

    func test_trial_WHEN_eligible_THEN_timelineIsShownAndCtaStartsTheTrial() {
        // GIVEN an eligible account
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // THEN the trial is explained and offered
        XCTAssertTrue(state.showsTrialTimeline)
        XCTAssertEqual(state.primaryButtonTitle, "Start My 7-day Free Trial")
    }

    // MARK: - Call to action

    func test_sheetButtonTitle_WHEN_monthlySelected_THEN_sellsAtTheMonthlyPrice() {
        // GIVEN an eligible account with monthly picked in the sheet
        var state = Stub.readyState(isEligibleForIntroOffer: true)
        state.sheetSelection = .monthly

        // THEN the sheet's button sells monthly even though the account could take a trial,
        // because the trial is only ever offered on the yearly plan
        XCTAssertEqual(state.sheetButtonTitle, "Subscribe • $16.99/mo")

        // AND the main screen is untouched
        XCTAssertEqual(state.primaryButtonTitle, "Start My 7-day Free Trial")
    }

    // MARK: - Disclaimer

    /// The trial line quotes the **billing period** price, not the per-month equivalent. Quoting
    /// "$6.08" where the customer will be charged "$72.98" would be a misrepresentation.
    func test_disclaimer_WHEN_trialOnYearly_THEN_quotesTheYearlyPrice() {
        // GIVEN an eligible account
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // WHEN the disclaimer is rendered
        let disclaimer = state.disclaimer

        // THEN it quotes the per-year price
        XCTAssertEqual(disclaimer?.headline, "Free for 7 days, then $72.98/year. Cancel anytime.")
        XCTAssertEqual(
            disclaimer?.detail,
            "You will be charged on the last day of your trial, unless you cancel before your free trial ends."
        )
    }

    func test_disclaimer_WHEN_monthlySelected_THEN_usesRecurringCopy() {
        // GIVEN monthly picked in the sheet
        var state = Stub.readyState(isEligibleForIntroOffer: true)
        state.sheetSelection = .monthly

        // WHEN the sheet's disclaimer is rendered
        let disclaimer = state.sheetDisclaimer

        // THEN it describes a recurring subscription, not a trial
        XCTAssertEqual(disclaimer?.headline, "$16.99 per month, billed monthly.")
        XCTAssertEqual(
            disclaimer?.detail,
            "Renews automatically unless cancelled at least 24 hours before expiry date."
        )
    }

    func test_disclaimer_WHEN_yearlyWithoutTrial_THEN_usesYearlyRecurringCopy() {
        // GIVEN an ineligible account on the yearly plan
        let state = Stub.readyState(isEligibleForIntroOffer: false)

        // THEN the yearly recurring copy is used
        XCTAssertEqual(state.disclaimer?.headline, "$72.98 per year, billed annually.")
    }

    /// Prices are formatted from the product's own locale, so a non-USD storefront must flow
    /// through unchanged rather than being reformatted or prefixed with "$".
    func test_disclaimer_WHEN_nonUSDStorefront_THEN_priceIsPassedThroughVerbatim() {
        // GIVEN a euro-priced yearly plan
        let euroOffer = Stub.offer(.yearly, price: "72,98 €", monthly: "6,08 €")
        let state = Stub.readyState(offers: [.yearly: euroOffer], isEligibleForIntroOffer: false)

        // THEN the euro formatting survives
        XCTAssertEqual(state.disclaimer?.headline, "72,98 € per year, billed annually.")
        XCTAssertEqual(state.primaryButtonTitle, "Subscribe • 6,08 €/mo")
    }

    // MARK: - Plan cards

    func test_planCard_WHEN_trialAvailable_THEN_yearlyCarriesTheTrialBadge() {
        // GIVEN an eligible account
        let state = Stub.readyState(isEligibleForIntroOffer: true)

        // THEN yearly is badged with the trial and monthly carries nothing
        XCTAssertEqual(state.badgeTitle(for: .yearly), "Best Value – 7-day Free Trial")
        XCTAssertNil(state.badgeTitle(for: .monthly))
    }

    func test_planCard_WHEN_noTrial_THEN_yearlyKeepsThePlainBestValueBadge() {
        // GIVEN an ineligible account
        let state = Stub.readyState(isEligibleForIntroOffer: false)

        // THEN the badge no longer promises a trial
        XCTAssertEqual(state.badgeTitle(for: .yearly), "Best Value")
    }

    func test_planCard_prices_THEN_useTheBillingPeriodSuffix() {
        // GIVEN a loaded paywall
        let state = Stub.readyState()

        // THEN each card shows its own billing period
        XCTAssertEqual(state.priceString(for: Stub.yearly), "$72.98/year")
        XCTAssertEqual(state.priceString(for: Stub.monthly), "$16.99/month")
        XCTAssertEqual(state.billingPeriodString(for: .yearly), "Billed annually")
        XCTAssertEqual(state.billingPeriodString(for: .monthly), "Billed monthly")
    }

    // MARK: - Screen state

    func test_skeleton_WHEN_loading_THEN_pricesAreNotClaimedAndPurchaseIsBlocked() {
        // GIVEN a paywall whose prices have not arrived
        let state = PaywallState()

        // THEN price-bearing text renders redacted and nothing can be bought yet
        XCTAssertTrue(state.isSkeleton)
        XCTAssertFalse(state.canPurchase)
        XCTAssertNil(state.disclaimer)

        // AND restore still works, because it needs no products
        XCTAssertTrue(state.canRestore)
    }
}
