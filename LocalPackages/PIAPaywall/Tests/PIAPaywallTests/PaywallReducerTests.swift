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

import XCTest

@testable import PIAPaywall

/// The reducer is a pure function, so every one of these is a synchronous value comparison.
final class PaywallReducerTests: XCTestCase {

    private func reduce(_ state: inout PaywallState, _ action: PaywallAction) -> PaywallEffect {
        PaywallReducer.reduce(into: &state, action: action)
    }

    // MARK: - Loading

    func test_onAppear_WHEN_stillLoading_THEN_loadsOffers() {
        // GIVEN a fresh paywall
        var state = PaywallState()

        // WHEN it appears
        let effect = reduce(&state, .onAppear)

        // THEN it asks for the catalogue
        XCTAssertEqual(effect, .batch([.observePurchaseIntents, .loadOffers]))
    }

    func test_offersResponse_WHEN_successful_THEN_becomesReadyWithYearlyPreselected() {
        // GIVEN a loading paywall
        var state = PaywallState()

        // WHEN both plans arrive
        let effect = reduce(&state, .offersResponse(.success(Stub.payload())))

        // THEN it is ready, selling yearly by default
        XCTAssertEqual(effect, .none)
        XCTAssertEqual(state.phase, .ready)
        XCTAssertEqual(state.defaultPlan, .yearly)
        XCTAssertEqual(state.sheetSelection, .yearly)
        XCTAssertEqual(state.trialOffer, PaywallTrialOffer(days: 7))
    }

    func test_offersResponse_WHEN_onlyMonthlyReturned_THEN_monthlyBecomesDefaultAndSheetIsHidden() {
        // GIVEN a loading paywall
        var state = PaywallState()

        // WHEN only the monthly plan comes back
        _ = reduce(&state, .offersResponse(.success(Stub.payload(offers: [.monthly: Stub.monthly]))))

        // THEN monthly is what the main button buys, and a one-row sheet is not offered
        XCTAssertEqual(state.defaultPlan, .monthly)
        XCTAssertFalse(state.showsOtherPlansButton)
    }

    /// The empty dictionary is a real case: `listPlanProducts()` can succeed with no products.
    /// Treating it as "loaded" would render a paywall with no prices and a dead button.
    func test_offersResponse_WHEN_successfulButEmpty_THEN_productsAreUnavailable() {
        // GIVEN a loading paywall
        var state = PaywallState()

        // WHEN the store succeeds with nothing to sell
        _ = reduce(&state, .offersResponse(.success(Stub.payload(offers: [:]))))

        // THEN it is treated as unavailable, not as loaded
        XCTAssertEqual(state.phase, .productsUnavailable)
    }

    func test_offersResponse_WHEN_failed_THEN_productsUnavailableAndRestoreStillWorks() {
        // GIVEN a loading paywall
        var state = PaywallState()

        // WHEN the catalogue fails to load
        let effect = reduce(&state, .offersResponse(.failure(.productsUnavailable)))

        // THEN the failure is inline, not a banner, and restore is unaffected
        XCTAssertEqual(effect, .none)
        XCTAssertEqual(state.phase, .productsUnavailable)
        XCTAssertTrue(state.canRestore)
        XCTAssertFalse(state.canPurchase)
    }

    func test_retry_WHEN_productsUnavailable_THEN_loadsOffersAgain() {
        // GIVEN a paywall that failed to load
        var state = PaywallState(phase: .productsUnavailable)

        // WHEN the customer retries
        let effect = reduce(&state, .retryTapped)

        // THEN it goes back to loading and refetches
        XCTAssertEqual(effect, .loadOffers)
        XCTAssertEqual(state.phase, .loadingProducts)
    }

    // MARK: - Plan sheet

    func test_seeOtherPlans_THEN_sheetOpensOnTheDefaultPlan() {
        // GIVEN a ready paywall selling yearly
        var state = Stub.readyState()

        // WHEN the sheet is opened
        _ = reduce(&state, .seeOtherPlansTapped)

        // THEN it starts on the plan the main screen was selling
        XCTAssertTrue(state.isPlanSheetPresented)
        XCTAssertEqual(state.sheetSelection, .yearly)
    }

    /// "Maybe Later" is a plain dismissal: the sheet's selection must not leak back to the main
    /// screen, which has no mockup for a non-default call to action.
    func test_planSheetDismissed_WHEN_monthlyWasSelected_THEN_selectionIsDiscarded() {
        // GIVEN an open sheet with monthly picked
        var state = Stub.readyState()
        _ = reduce(&state, .seeOtherPlansTapped)
        _ = reduce(&state, .planSelected(.monthly))
        XCTAssertEqual(state.sheetSelection, .monthly)

        // WHEN it is dismissed
        _ = reduce(&state, .planSheetDismissed)

        // THEN the main screen still sells yearly
        XCTAssertFalse(state.isPlanSheetPresented)
        XCTAssertEqual(state.sheetSelection, .yearly)
        XCTAssertEqual(state.defaultPlan, .yearly)
    }

    func test_planSelected_WHEN_planHasNoOffer_THEN_selectionIsUnchanged() {
        // GIVEN a paywall where only yearly is purchasable
        var state = Stub.readyState(offers: [.yearly: Stub.yearly])

        // WHEN something selects monthly anyway
        _ = reduce(&state, .planSelected(.monthly))

        // THEN the selection stays on a plan that can actually be bought
        XCTAssertEqual(state.sheetSelection, .yearly)
    }

    // MARK: - Purchase

    func test_purchaseTapped_fromMainScreen_THEN_checksEntitlementForTheDefaultPlan() {
        // GIVEN a ready paywall selling yearly
        var state = Stub.readyState()

        // WHEN the main call to action is tapped
        let effect = reduce(&state, .purchaseTapped(source: .mainScreen))

        // THEN the entitlement check runs first, for the default plan
        XCTAssertEqual(effect, .checkEntitlementThenPurchase(.plan(.yearly)))
        XCTAssertEqual(state.activity, .purchasing)
    }

    func test_purchaseTapped_fromSheet_THEN_buysTheSheetSelection() {
        // GIVEN an open sheet with monthly picked
        var state = Stub.readyState()
        _ = reduce(&state, .seeOtherPlansTapped)
        _ = reduce(&state, .planSelected(.monthly))

        // WHEN the sheet's call to action is tapped
        let effect = reduce(&state, .purchaseTapped(source: .planSheet))

        // THEN monthly is purchased, and the sheet closes so alerts are not hidden behind it
        XCTAssertEqual(effect, .checkEntitlementThenPurchase(.plan(.monthly)))
        XCTAssertFalse(state.isPlanSheetPresented)
    }

    /// The old paywall wrote `isPurchasing` but never read it, so a double tap started two
    /// overlapping StoreKit operations.
    func test_purchaseTapped_WHEN_alreadyPurchasing_THEN_isIgnored() {
        // GIVEN a purchase already in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN the button is tapped again
        let effect = reduce(&state, .purchaseTapped(source: .mainScreen))

        // THEN nothing further happens
        XCTAssertEqual(effect, .none)
    }

    func test_restoreTapped_WHEN_purchasing_THEN_isIgnored() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN restore is tapped
        let effect = reduce(&state, .restoreTapped)

        // THEN it does not run alongside the purchase
        XCTAssertEqual(effect, .none)
        XCTAssertEqual(state.activity, .purchasing)
    }

    func test_purchaseTapped_WHEN_productsUnavailable_THEN_isIgnored() {
        // GIVEN a paywall with nothing to sell
        var state = PaywallState(phase: .productsUnavailable)

        // WHEN the call to action is somehow tapped
        let effect = reduce(&state, .purchaseTapped(source: .mainScreen))

        // THEN no purchase is attempted
        XCTAssertEqual(effect, .none)
        XCTAssertEqual(state.activity, .idle)
    }

    /// Charging a customer who already owns a subscription is the worst failure this screen has.
    func test_existingEntitlementFound_THEN_offersRestoreAndDoesNotPurchase() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN the App Store already has an entitlement
        let effect = reduce(&state, .existingEntitlementFound)

        // THEN the purchase stops and the customer is offered a restore
        XCTAssertEqual(effect, .none)
        XCTAssertEqual(state.alert, .existingEntitlement)
        XCTAssertEqual(state.activity, .idle)
    }

    func test_purchaseSucceeded_WHEN_transactionIsExpired_THEN_finishesItAndDoesNotSignUp() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN the App Store returns an already-expired transaction
        let effect = reduce(&state, .purchaseSucceeded(isExpired: true))

        // THEN it is finished and the signup never starts
        guard case .batch(let effects) = effect else {
            return XCTFail("Expected a batch, got \(effect)")
        }
        XCTAssertTrue(effects.contains(.finishPendingTransaction))
        XCTAssertFalse(effects.contains(.emit(.didPurchase)))
        XCTAssertEqual(state.activity, .idle)
    }

    func test_purchaseSucceeded_THEN_emitsDidPurchase() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN it succeeds
        let effect = reduce(&state, .purchaseSucceeded(isExpired: false))

        // THEN the host is told to start account creation
        XCTAssertEqual(effect, .emit(.didPurchase))
        XCTAssertEqual(state.activity, .idle)
    }

    func test_purchaseFailed_WHEN_userCancelled_THEN_saysNothing() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN the customer dismisses the App Store sheet
        let effect = reduce(&state, .purchaseFailed(.userCancelled))

        // THEN no banner and no alert — cancelling is not an error
        XCTAssertEqual(effect, .none)
        XCTAssertNil(state.alert)
        XCTAssertEqual(state.activity, .idle)
    }

    func test_purchaseFailed_WHEN_pending_THEN_warnsTheCustomer() {
        // GIVEN a purchase in flight
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))

        // WHEN it needs external approval
        let effect = reduce(&state, .purchaseFailed(.purchasePending))

        // THEN a warning is emitted
        guard case .emit(.showWarning) = effect else {
            return XCTFail("Expected a warning, got \(effect)")
        }
    }

    // MARK: - Restore

    func test_restore_WHEN_nothingToRestore_THEN_showsTheEmptyAlert() {
        // GIVEN a restore in flight
        var state = Stub.readyState()
        _ = reduce(&state, .restoreTapped)

        // WHEN no receipt is found
        _ = reduce(&state, .restoreFailedNothingToRestore)

        // THEN the "no subscription found" alert appears
        XCTAssertEqual(state.alert, .nothingToRestore)
        XCTAssertEqual(state.activity, .idle)
    }

    func test_restore_WHEN_loginWithReceiptFails_THEN_showsTheFailureAlert() {
        // GIVEN a restore in flight
        var state = Stub.readyState()
        _ = reduce(&state, .restoreTapped)

        // WHEN the receipt cannot be signed in with
        _ = reduce(&state, .restoreFailedBadReceipt)

        // THEN a different alert appears
        XCTAssertEqual(state.alert, .restoreFailed)
    }

    func test_restore_WHEN_successful_THEN_emitsDidAuthenticate() {
        // GIVEN a restore in flight
        var state = Stub.readyState()
        _ = reduce(&state, .restoreTapped)

        // WHEN it succeeds
        let effect = reduce(&state, .restoreSucceeded)

        // THEN the host completes the flow as a login
        XCTAssertEqual(effect, .emit(.didAuthenticate))
    }

    func test_alertRestoreConfirmed_THEN_dismissesTheAlertAndRestores() {
        // GIVEN the "subscription found" alert is up
        var state = Stub.readyState()
        _ = reduce(&state, .purchaseTapped(source: .mainScreen))
        _ = reduce(&state, .existingEntitlementFound)

        // WHEN the customer chooses Restore
        let effect = reduce(&state, .alertRestoreConfirmed)

        // THEN the alert closes and a restore starts
        XCTAssertEqual(effect, .restore)
        XCTAssertNil(state.alert)
        XCTAssertEqual(state.activity, .restoring)
    }

    // MARK: - Misc

    func test_loginTapped_THEN_asksTheHostToShowLogin() {
        // GIVEN an idle paywall
        var state = Stub.readyState()

        // WHEN Log In is tapped
        let effect = reduce(&state, .loginTapped)

        // THEN the host is asked to navigate; the paywall itself knows nothing about login
        XCTAssertEqual(effect, .emit(.requestLogin))
    }

    func test_closeTapped_THEN_asksTheHostToDismiss() {
        // GIVEN a dismissable paywall
        var state = Stub.readyState()

        // WHEN close is tapped
        let effect = reduce(&state, .closeTapped)

        // THEN the host dismisses it
        XCTAssertEqual(effect, .emit(.didCancel))
    }

    func test_layoutChanged_THEN_isStored() {
        // GIVEN a compact paywall
        var state = PaywallState()

        // WHEN it is rendered on a landscape iPad
        _ = reduce(&state, .layoutChanged(.wide))

        // THEN the layout is remembered
        XCTAssertEqual(state.layout, .wide)
    }
}
