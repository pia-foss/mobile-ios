//
//  PaywallStoreTests.swift
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
import Foundation
import PIALibrary
import Testing

@testable import PIAPaywall

/// Covers the part the reducer cannot: that effects are actually run, in the right order, and that
/// the non-`Equatable` payloads reach the host intact.
///
/// `TestStore` runs the same reducer and the same effect machinery as `PaywallStore`, with one
/// difference: actions produced by effects are queued rather than applied, and the test decides when
/// to let each one in. That is what makes an entitlement check followed by a charge assertable in
/// order rather than raced.
@MainActor
struct PaywallStoreTests {

    /// A fresh spy per test, because Swift Testing builds a new suite instance for each one.
    private let spy = DependencySpy()

    private func makeStore(state: Paywall.State = Paywall.State()) -> TestStore<Paywall.State, Paywall.Action> {
        TestStore(
            initial: state,
            reduce: Paywall.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    // MARK: - Loading

    @Test("Appearing fetches the catalogue once and becomes ready")
    func onAppearLoadsOffersAndBecomesReady() async throws {
        // GIVEN a store with both plans available
        let sut = makeStore()

        // WHEN it appears
        sut.send(.onAppear)

        // THEN the catalogue is fetched once and the screen is ready
        _ = try #require(await sut.receive())
        #expect(spy.loadOffersCallCount == 1)
        #expect(sut.state.phase == .ready)
    }

    @Test("A catalogue that cannot load leaves the paywall unavailable")
    func onAppearWithFailingOffersIsUnavailable() async throws {
        // GIVEN a store whose catalogue cannot load
        spy.offersResult = .failure(.productsUnavailable)
        let sut = makeStore()

        // WHEN it appears
        sut.send(.onAppear)

        // THEN the screen reports it, rather than spinning forever as the old paywall did
        _ = try #require(await sut.receive())
        #expect(sut.state.phase == .productsUnavailable)
    }

    @Test("Retrying picks up a catalogue that has since become available")
    func retryFetchesTheCatalogueAgain() async throws {
        // GIVEN a paywall that failed to load
        spy.offersResult = .failure(.productsUnavailable)
        let sut = makeStore()
        sut.send(.onAppear)
        _ = try #require(await sut.receive())

        // WHEN the customer retries and the catalogue is available this time
        spy.offersResult = .success(Stub.payload())
        sut.send(.retryTapped)

        // THEN the second fetch is what the screen renders
        _ = try #require(await sut.receive())
        #expect(spy.loadOffersCallCount == 2)
        #expect(sut.state.phase == .ready)
    }

    /// The intent stream and the offers load run under separate ids, so re-appearing restarts both
    /// rather than one cancelling the other.
    @Test("Re-appearing reloads and resubscribes")
    func onAppearTwiceReloadsAndResubscribes() async throws {
        // GIVEN a paywall that has already appeared once
        let sut = makeStore()
        sut.send(.onAppear)
        _ = try #require(await sut.receive())

        // WHEN it appears again
        sut.send(.onAppear)
        _ = try #require(await sut.receive())

        // THEN both effects ran again
        #expect(spy.loadOffersCallCount == 2)
        #expect(spy.purchaseIntentsCallCount == 2)
    }

    // MARK: - Purchase

    @Test("The entitlement check runs before any charge")
    func purchaseChecksEntitlementBeforeCharging() async throws {
        // GIVEN a ready store
        let sut = makeStore(state: Stub.readyState())

        // WHEN a purchase is started
        sut.send(.purchaseTapped(source: .mainScreen))
        _ = try #require(await sut.receive())

        // THEN the entitlement check ran first
        #expect(Array(spy.callOrder.prefix(2)) == ["hasExistingEntitlement", "purchase"])
        #expect(spy.purchasedPlans == [.plan(.yearly)])
    }

    /// The sheet's call to action buys the sheet's selection, not the plan the main screen sells.
    @Test("Buying from the sheet charges the sheet's selection")
    func purchaseFromTheSheetChargesTheSheetSelection() async throws {
        // GIVEN a sheet showing monthly selected over a yearly default
        var state = Stub.readyState()
        state.sheetSelection = .monthly
        state.isPlanSheetPresented = true
        let sut = makeStore(state: state)

        // WHEN the sheet's button is tapped
        sut.send(.purchaseTapped(source: .planSheet))
        _ = try #require(await sut.receive())

        // THEN monthly is what reaches StoreKit
        #expect(spy.purchasedPlans == [.plan(.monthly)])
    }

    @Test("An account that already owns a subscription is never charged")
    func purchaseWithExistingEntitlementNeverCharges() async {
        // GIVEN an App Store account that already owns a subscription
        spy.hasEntitlement = true
        let sut = makeStore(state: Stub.readyState())

        // WHEN a purchase is started
        sut.send(.purchaseTapped(source: .mainScreen))

        // THEN no charge is attempted and the customer is offered a restore
        #expect(await sut.receive() == .existingEntitlementFound)
        #expect(spy.purchasedPlans.isEmpty)
        #expect(sut.state.alert == .existingEntitlement)
    }

    @Test("The host receives the very transaction the App Store returned")
    func successfulPurchaseEmitsTheTransaction() async throws {
        // GIVEN a purchase that will succeed
        spy.purchaseResult = .success(InAppTransactionStub(identifier: "txn-42"))
        let sut = makeStore(state: Stub.readyState())

        // WHEN it completes
        sut.send(.purchaseTapped(source: .mainScreen))
        _ = try #require(await sut.receive())
        await sut.finish()

        // THEN the host receives the very transaction the App Store returned
        let emitted = try #require(spy.purchasedTransactions.last)
        #expect(emitted.identifier == "txn-42")
    }

    @Test("An expired transaction is finished, warned about, and creates no account")
    func expiredTransactionIsFinishedAndEmitsNoPurchase() async throws {
        // GIVEN an already-expired transaction
        spy.purchaseResult = .success(InAppTransactionStub(identifier: "txn-old", isExpired: true))
        let sut = makeStore(state: Stub.readyState())

        // WHEN the purchase completes
        sut.send(.purchaseTapped(source: .mainScreen))
        _ = try #require(await sut.receive())
        await sut.finish()

        // THEN it is finished exactly once so the App Store stops redelivering it
        #expect(spy.finishedTransactions == ["txn-old"])

        // AND no account creation is started
        #expect(spy.purchasedTransactions.isEmpty)

        // AND the customer is told why nothing happened, only after the transaction was dealt with
        #expect(spy.emittedWarnings.count == 1)
        #expect(Array(spy.callOrder.suffix(2)) == ["finishTransaction", "emit"])
    }

    @Test("A double tap only charges once")
    func doubleTapOnlyChargesOnce() async throws {
        // GIVEN a ready store
        let sut = makeStore(state: Stub.readyState())

        // WHEN the button is tapped twice in a row
        sut.send(.purchaseTapped(source: .mainScreen))
        sut.send(.purchaseTapped(source: .mainScreen))
        _ = try #require(await sut.receive())

        // THEN only one purchase reaches StoreKit
        #expect(spy.purchasedPlans == [.plan(.yearly)])
        #expect(sut.unconsumedActionCount == 0)
    }

    @Test("A failed purchase emits the mapped message")
    func failedPurchaseEmitsTheMappedMessage() async throws {
        // GIVEN a purchase that fails with a message worth showing
        spy.purchaseResult = .failure(.failed(message: "Purchase failed"))
        let sut = makeStore(state: Stub.readyState())

        // WHEN it completes
        sut.send(.purchaseTapped(source: .mainScreen))
        _ = try #require(await sut.receive())
        await sut.finish()

        // THEN the host is asked to raise that message
        #expect(spy.emittedWarnings == ["Purchase failed"])
    }

    /// A cancelled App Store sheet is not a failure, so nothing is shown at all.
    @Test("A cancelled purchase says nothing and returns to idle")
    func cancelledPurchaseEmitsNothing() async throws {
        // GIVEN a customer who dismisses the App Store sheet
        spy.purchaseResult = .failure(.userCancelled)
        let sut = makeStore(state: Stub.readyState())

        // WHEN the purchase comes back
        sut.send(.purchaseTapped(source: .mainScreen))
        _ = try #require(await sut.receive())
        await sut.finish()

        // THEN the screen simply returns to idle
        #expect(spy.emittedOutputs.isEmpty)
        #expect(sut.state.activity == .idle)
    }

    // MARK: - Restore

    @Test("A successful restore hands the signed-in account to the host")
    func successfulRestoreEmitsTheAuthenticatedUser() async throws {
        // GIVEN a restorable subscription
        let sut = makeStore(state: Stub.readyState())

        // WHEN restore runs
        sut.send(.restoreTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        // THEN the host receives the signed-in account
        let user = try #require(spy.authenticatedUsers.last)
        #expect(user.credentials.username == "p0000000")
    }

    @Test("No receipt raises the empty alert")
    func restoreWithNothingToRestoreShowsTheEmptyAlert() async {
        // GIVEN an App Store account with no receipt
        spy.restoreResult = .failure(.nothingToRestore)
        let sut = makeStore(state: Stub.readyState())

        // WHEN restore runs
        sut.send(.restoreTapped)

        // THEN the "no subscription found" alert appears
        #expect(await sut.receive() == .restoreFailedNothingToRestore)
        #expect(sut.state.alert == .nothingToRestore)
    }

    /// A receipt that exists but cannot be signed in with is a different problem, and the design
    /// gives it different wording.
    @Test("A receipt that cannot be signed in with raises the other alert")
    func restoreWithFailedLoginShowsTheRestoreFailedAlert() async {
        // GIVEN a receipt that cannot be exchanged for an account
        spy.restoreResult = .failure(.restoreLoginFailed)
        let sut = makeStore(state: Stub.readyState())

        // WHEN restore runs
        sut.send(.restoreTapped)

        // THEN the other alert appears
        #expect(await sut.receive() == .restoreFailedBadReceipt)
        #expect(sut.state.alert == .restoreFailed)
    }

    // MARK: - Navigation outputs

    @Test("Log In asks the host for the login screen")
    func loginTappedAsksTheHostForLogin() async {
        // GIVEN an idle paywall
        let sut = makeStore(state: Stub.readyState())

        // WHEN the login button is tapped
        sut.send(.loginTapped)
        await sut.finish()

        // THEN the host is asked to push it, and the paywall decides nothing more
        #expect(spy.didRequestLogin)
    }

    // MARK: - Lifecycle

    /// Uses the real `PaywallStore` rather than `TestStore`: the claim is about the store the app
    /// actually runs, including that its `@Published` state reaches a view.
    @Test("The real store publishes state and runs its effects")
    func theRealStorePublishesStateAndRunsItsEffects() async {
        // GIVEN the store the app builds
        let sut = PaywallStore(dependencies: spy.makeDependencies())

        // WHEN the paywall appears
        sut.send(.onAppear)

        // THEN the offers arrived through the effect and are visible on `state`
        await waitUntil { sut.state.phase == .ready }
        #expect(spy.loadOffersCallCount == 1)
    }

    /// `Effect.task` hands its action to the sink without checking cancellation, so this is what
    /// `Effect.cancellableTask` exists for: the work still runs, but its action is dropped.
    @Test("Work cancelled mid-flight stops reporting back")
    func cancelAllEffectsStopsInFlightWorkReportingBack() async {
        // GIVEN a store with a purchase in flight
        let sut = PaywallStore(initialState: Stub.readyState(), dependencies: spy.makeDependencies())
        sut.send(.purchaseTapped(source: .mainScreen))

        // WHEN the paywall is torn down before it completes
        sut.cancelAllEffects()

        // AND the cancelled work runs to completion anyway
        await waitUntil { self.spy.purchasedPlans.isEmpty == false }

        // THEN nothing is emitted to a host that is no longer listening
        #expect(spy.emittedOutputs.isEmpty)
    }

    // MARK: - Helpers

    /// Waits for the store's effect tasks to drive `condition` true.
    ///
    /// A deadline rather than a fixed number of yields: tests run in parallel, so how many main-actor
    /// hops an effect needs is not something a test can count on.
    private func waitUntil(
        within seconds: TimeInterval = 2,
        sourceLocation: SourceLocation = #_sourceLocation,
        _ condition: () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if condition() { return }
            await Task.yield()
        }
        Issue.record("Condition was not met within \(seconds)s", sourceLocation: sourceLocation)
    }
}
