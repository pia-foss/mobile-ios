//
//  PaywallReducerTests.swift
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

import CoreArchitecture
import Testing

@testable import PIAPaywall

/// The reducer is a pure function, so every one of these is a synchronous value comparison.
///
/// `Effect` carries closures and is not `Equatable`, so what a test can claim here is the state
/// transition and *whether* work was returned. Which work it was — which plan reaches StoreKit,
/// which output the host receives — is asserted in `PaywallStoreTests`, where the effect actually
/// runs against a spy.
@MainActor
struct PaywallReducerTests {

    private let sut = Paywall.Reducer(dependencies: .test())

    private func reduce(_ state: inout Paywall.State, _ action: Paywall.Action) -> Effect<Paywall.Action>? {
        sut.reduce(&state, action)
    }

    // MARK: - Loading

    @Test("Appearing asks for the catalogue")
    func onAppearLoadsOffers() {
        // GIVEN a fresh paywall
        var state = Paywall.State()

        // WHEN it appears
        let effect = reduce(&state, .onAppear)

        // THEN it asks for the catalogue
        #expect(effect != nil)
    }

    @Test("Both plans arriving leaves the paywall ready and selling yearly")
    func offersBecomeReadyWithYearlyPreselected() {
        // GIVEN a loading paywall
        var state = Paywall.State()

        // WHEN both plans arrive
        let effect = reduce(&state, .offersResponse(.success(Stub.payload())))

        // THEN it is ready, selling yearly by default
        #expect(effect == nil)
        #expect(state.phase == .ready)
        #expect(state.defaultPlan == .yearly)
        #expect(state.sheetSelection == .yearly)
        #expect(state.trialOffer == PaywallTrialOffer(days: 7))
    }

    @Test("With only monthly on sale, monthly becomes the default and the sheet is hidden")
    func onlyMonthlyMakesMonthlyTheDefault() {
        // GIVEN a loading paywall
        var state = Paywall.State()

        // WHEN only the monthly plan comes back
        _ = reduce(&state, .offersResponse(.success(Stub.payload(offers: [.monthly: Stub.monthly]))))

        // THEN monthly is what the main button buys, and a one-row sheet is not offered
        #expect(state.defaultPlan == .monthly)
        #expect(state.showsOtherPlansButton == false)
    }

    /// An empty dictionary is a real case: `listPlanProducts()` can succeed with no products.
    /// Treating it as "loaded" would render a paywall with no prices and a dead button. A failure
    /// lands in the same place, so both are covered here.
    @Test(
        "Nothing to sell leaves the paywall unavailable, however that is reported",
        arguments: [
            Result<OffersPayload, PaywallError>.success(Stub.payload(offers: [:])),
            .failure(.productsUnavailable)
        ]
    )
    func nothingToSellIsUnavailable(response: Result<OffersPayload, PaywallError>) {
        // GIVEN a loading paywall
        var state = Paywall.State()

        // WHEN the catalogue comes back with nothing purchasable
        let effect = reduce(&state, .offersResponse(response))

        // THEN the failure is inline, not a banner, and restore is unaffected
        #expect(effect == nil)
        #expect(state.phase == .productsUnavailable)
        #expect(state.canRestore)
        #expect(state.canPurchase == false)
    }

    @Test("Retrying an unavailable paywall refetches")
    func retryLoadsOffersAgain() {
        // GIVEN a paywall that failed to load
        var state = Paywall.State(phase: .productsUnavailable)

        // WHEN the customer retries
        let effect = reduce(&state, .retryTapped)

        // THEN it goes back to loading and refetches
        #expect(effect != nil)
        #expect(state.phase == .loadingProducts)
    }

    @Test("Retrying while already loading is ignored")
    func retryWhileLoadingIsIgnored() {
        // GIVEN a paywall that is already fetching
        var state = Paywall.State(phase: .loadingProducts)

        // WHEN retry arrives anyway
        let effect = reduce(&state, .retryTapped)

        // THEN nothing is refetched
        #expect(effect == nil)
    }

    /// The paywall disappears when it is covered as well as when it is torn down, so a purchase that
    /// settles behind the login screen must still reach the host.
    @Test("Disappearing leaves an in-flight purchase running")
    func disappearingKeepsThePurchaseAlive() {
        // GIVEN a paywall with a purchase in flight
        var state = Stub.readyState()
        state.activity = .purchasing

        // WHEN it disappears
        let effect = reduce(&state, .disappeared)

        // THEN only the intent subscription is torn down, and the purchase is still running
        #expect(effect != nil)
        #expect(state.activity == .purchasing)
    }

    // MARK: - Plan sheet

    @Test("The sheet opens on the plan the main screen was selling")
    func sheetOpensOnTheDefaultPlan() {
        // GIVEN a ready paywall selling yearly
        var state = Stub.readyState()

        // WHEN the sheet is opened
        _ = reduce(&state, .seeOtherPlansTapped)

        // THEN it starts on the plan the main screen was selling
        #expect(state.isPlanSheetPresented)
        #expect(state.sheetSelection == .yearly)
    }

    /// "Maybe Later" is a plain dismissal: the sheet's selection must not leak back to the main
    /// screen, which has no mockup for a non-default call to action.
    @Test("Dismissing the sheet discards its selection")
    func dismissingTheSheetDiscardsTheSelection() {
        // GIVEN an open sheet with monthly picked
        var state = Stub.readyState()
        _ = reduce(&state, .seeOtherPlansTapped)
        _ = reduce(&state, .planSelected(.monthly))
        #expect(state.sheetSelection == .monthly)

        // WHEN it is dismissed
        _ = reduce(&state, .planSheetDismissed)

        // THEN the main screen still sells yearly
        #expect(state.isPlanSheetPresented == false)
        #expect(state.sheetSelection == .yearly)
        #expect(state.defaultPlan == .yearly)
    }

    @Test("Selecting a plan with no offer leaves the selection alone")
    func selectingAPlanWithoutAnOfferIsIgnored() {
        // GIVEN a paywall where only yearly is purchasable
        var state = Stub.readyState(offers: [.yearly: Stub.yearly])

        // WHEN something selects monthly anyway
        _ = reduce(&state, .planSelected(.monthly))

        // THEN the selection stays on a plan that can actually be bought
        #expect(state.sheetSelection == .yearly)
    }

    // MARK: - Purchase

    @Test("Tapping the main call to action starts purchasing")
    func purchaseFromMainScreenStartsPurchasing() {
        // GIVEN a ready paywall selling yearly
        var state = Stub.readyState()

        // WHEN the main call to action is tapped
        let effect = reduce(&state, .purchaseTapped(source: .mainScreen))

        // THEN work starts and the button shows its spinner
        #expect(effect != nil)
        #expect(state.activity == .purchasing)
    }

    @Test("Buying from the sheet closes it, so an alert is not hidden behind it")
    func purchaseFromSheetClosesTheSheet() {
        // GIVEN an open sheet with monthly picked
        var state = Stub.readyState()
        _ = reduce(&state, .seeOtherPlansTapped)
        _ = reduce(&state, .planSelected(.monthly))

        // WHEN the sheet's call to action is tapped
        let effect = reduce(&state, .purchaseTapped(source: .planSheet))

        // THEN the sheet closes so alerts are not hidden behind it
        #expect(effect != nil)
        #expect(state.isPlanSheetPresented == false)
    }

    /// The old paywall wrote `isPurchasing` but never read it, so a double tap started two
    /// overlapping StoreKit operations.
    @Test("A second tap while purchasing is ignored")
    func purchaseWhileAlreadyPurchasingIsIgnored() {
        // GIVEN a purchase already in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN the button is tapped again
        let effect = reduce(&state, .purchaseTapped(source: .mainScreen))

        // THEN nothing further happens
        #expect(effect == nil)
    }

    @Test("Restore does not run alongside a purchase")
    func restoreWhilePurchasingIsIgnored() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN restore is tapped
        let effect = reduce(&state, .restoreTapped)

        // THEN it does not run alongside the purchase
        #expect(effect == nil)
        #expect(state.activity == .purchasing)
    }

    @Test("With nothing to sell, the call to action does nothing")
    func purchaseWhileProductsUnavailableIsIgnored() {
        // GIVEN a paywall with nothing to sell
        var state = Paywall.State(phase: .productsUnavailable)

        // WHEN the call to action is somehow tapped
        let effect = reduce(&state, .purchaseTapped(source: .mainScreen))

        // THEN no purchase is attempted
        #expect(effect == nil)
        #expect(state.activity == .idle)
    }

    /// Charging a customer who already owns a subscription is the worst failure this screen has.
    @Test("An existing entitlement stops the purchase and offers a restore")
    func existingEntitlementOffersRestore() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN the App Store already has an entitlement
        let effect = reduce(&state, .existingEntitlementFound)

        // THEN the purchase stops and the customer is offered a restore
        #expect(effect == nil)
        #expect(state.alert == .existingEntitlement)
        #expect(state.activity == .idle)
    }

    @Test("An expired transaction returns to idle without raising an alert")
    func expiredTransactionReturnsToIdle() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN the App Store returns an already-expired transaction
        let effect = reduce(&state, .purchaseSucceeded(Stub.transaction(isExpired: true)))

        // THEN the transaction is dealt with as an effect, and the screen is usable again
        #expect(effect != nil)
        #expect(state.activity == .idle)
        #expect(state.alert == nil)
    }

    @Test("A successful purchase returns to idle")
    func purchaseSucceededReturnsToIdle() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN it succeeds
        let effect = reduce(&state, .purchaseSucceeded(Stub.transaction()))

        // THEN the host is told to start account creation
        #expect(effect != nil)
        #expect(state.activity == .idle)
    }

    /// A cancelled App Store sheet is not an error, so it is the one failure that says nothing at
    /// all. Every other failure has to reach the customer somehow.
    @Test(
        "Only a cancellation is silent",
        arguments: [
            (PaywallError.userCancelled, false),
            (.purchasePending, true),
            (.failed(message: "Purchase failed"), true)
        ]
    )
    func purchaseFailureIsReportedUnlessCancelled(error: PaywallError, reports: Bool) {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN it fails
        let effect = reduce(&state, .purchaseFailed(error))

        // THEN only the cancellation passes without a word
        #expect((effect != nil) == reports)
        #expect(state.alert == nil)
        #expect(state.activity == .idle)
    }

    // MARK: - Restore

    // The two restore failures differ only in wording, and the design gives each its own alert:
    // a receipt that cannot be signed in with is a different problem from no receipt at all. They
    // stay two tests rather than one parameterized test because `Paywall.Action` cannot be
    // `Sendable` — it carries `InAppTransaction`, `UserAccount` and `AppStoreProduct` — and
    // parameterized arguments must be.

    @Test("No receipt at all raises the empty alert")
    func restoreWithNothingToRestoreRaisesTheEmptyAlert() {
        // GIVEN a restore in flight
        var state = Stub.readyState()
        _ = reduce(&state, .restoreTapped)

        // WHEN no receipt is found
        _ = reduce(&state, .restoreFailedNothingToRestore)

        // THEN the "no subscription found" alert appears
        #expect(state.alert == .nothingToRestore)
        #expect(state.activity == .idle)
    }

    @Test("A receipt that cannot be signed in with raises the failure alert")
    func restoreWithBadReceiptRaisesTheFailureAlert() {
        // GIVEN a restore in flight
        var state = Stub.readyState()
        _ = reduce(&state, .restoreTapped)

        // WHEN the receipt cannot be exchanged for an account
        _ = reduce(&state, .restoreFailedBadReceipt)

        // THEN a different alert appears
        #expect(state.alert == .restoreFailed)
        #expect(state.activity == .idle)
    }

    @Test("A successful restore returns to idle")
    func restoreSucceededReturnsToIdle() {
        // GIVEN a restore in flight
        var state = Stub.readyState()
        _ = reduce(&state, .restoreTapped)

        // WHEN it succeeds
        let effect = reduce(&state, .restoreSucceeded(Stub.account))

        // THEN the host completes the flow as a login
        #expect(effect != nil)
        #expect(state.activity == .idle)
    }

    @Test("Confirming the entitlement alert closes it and starts a restore")
    func alertRestoreConfirmedStartsRestore() {
        // GIVEN the "subscription found" alert is up
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))
        _ = reduce(&state, .existingEntitlementFound)

        // WHEN the customer chooses Restore
        let effect = reduce(&state, .alertRestoreConfirmed)

        // THEN the alert closes and a restore starts
        #expect(effect != nil)
        #expect(state.alert == nil)
        #expect(state.activity == .restoring)
    }

    // MARK: - Misc

    @Test("Log In asks the host to navigate")
    func loginTappedAsksTheHostToShowLogin() {
        // GIVEN an idle paywall
        var state = Stub.readyState()

        // WHEN Log In is tapped
        let effect = reduce(&state, .loginTapped)

        // THEN the host is asked to navigate; the paywall itself knows nothing about login
        #expect(effect != nil)
    }

    @Test("Log In is ignored mid-charge")
    func loginWhilePurchasingIsIgnored() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN Log In is tapped anyway
        let effect = reduce(&state, .loginTapped)

        // THEN the flow is not navigated away from a charge in progress
        #expect(effect == nil)
    }

    @Test("Close asks the host to dismiss")
    func closeTappedAsksTheHostToDismiss() {
        // GIVEN a dismissable paywall
        var state = Stub.readyState()

        // WHEN close is tapped
        let effect = reduce(&state, .closeTapped)

        // THEN the host dismisses it
        #expect(effect != nil)
    }

    @Test("Dismissing an alert clears it and does nothing else")
    func alertDismissedClearsTheAlert() {
        // GIVEN an alert on screen
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))
        _ = reduce(&state, .existingEntitlementFound)

        // WHEN it is dismissed
        let effect = reduce(&state, .alertDismissed)

        // THEN nothing else happens
        #expect(effect == nil)
        #expect(state.alert == nil)
    }

    @Test("A layout change is remembered")
    func layoutChangeIsStored() {
        // GIVEN a compact paywall
        var state = Paywall.State()

        // WHEN it is rendered on a landscape iPad
        _ = reduce(&state, .layoutChanged(.wide))

        // THEN the layout is remembered
        #expect(state.layout == .wide)
    }
}
