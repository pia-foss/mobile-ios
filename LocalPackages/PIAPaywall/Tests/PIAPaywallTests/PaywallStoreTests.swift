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

import Combine
import PIALibrary
import XCTest

@testable import PIAPaywall

/// Covers the part the reducer cannot: that effects are actually run, in the right order, and that
/// the non-`Equatable` payloads reach the host intact.
@MainActor
final class PaywallStoreTests: XCTestCase {

    @MainActor
    private final class Fixture {
        let spy = DependencySpy()
        var cancellables = Set<AnyCancellable>()
        private(set) var outputs: [PaywallOutput] = []

        func makeStore(state: PaywallState = PaywallState()) -> PaywallStore {
            let store = PaywallStore(initialState: state, dependencies: spy.makeDependencies())
            store.output
                .sink { [weak self] in self?.outputs.append($0) }
                .store(in: &cancellables)
            return store
        }

        /// Lets the store's detached `Task`s run to completion.
        func settle() async {
            for _ in 0..<10 {
                await Task.yield()
            }
        }
    }

    private var fixture: Fixture!

    override func setUp() {
        super.setUp()
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        super.tearDown()
    }

    // MARK: - Loading

    func test_onAppear_THEN_loadsOffersAndBecomesReady() async {
        // GIVEN a store with both plans available
        let sut = fixture.makeStore()

        // WHEN it appears
        sut.send(.onAppear)
        await fixture.settle()

        // THEN the catalogue is fetched once and the screen is ready
        XCTAssertEqual(fixture.spy.loadOffersCallCount, 1)
        XCTAssertEqual(sut.state.phase, .ready)
    }

    func test_onAppear_WHEN_offersFail_THEN_phaseIsUnavailable() async {
        // GIVEN a store whose catalogue cannot load
        fixture.spy.offersResult = .failure(.productsUnavailable)
        let sut = fixture.makeStore()

        // WHEN it appears
        sut.send(.onAppear)
        await fixture.settle()

        // THEN the screen reports it, rather than spinning forever as the old paywall did
        XCTAssertEqual(sut.state.phase, .productsUnavailable)
    }

    // MARK: - Purchase

    func test_purchase_THEN_checksEntitlementBeforeCharging() async {
        // GIVEN a ready store
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN a purchase is started
        sut.send(.purchaseTapped(source: .mainScreen))
        await fixture.settle()

        // THEN the entitlement check ran first
        XCTAssertEqual(fixture.spy.callOrder, ["hasExistingEntitlement", "purchase"])
        XCTAssertEqual(fixture.spy.purchasedPlans, [.yearly])
    }

    func test_purchase_WHEN_entitlementExists_THEN_neverCharges() async {
        // GIVEN an App Store account that already owns a subscription
        fixture.spy.hasEntitlement = true
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN a purchase is started
        sut.send(.purchaseTapped(source: .mainScreen))
        await fixture.settle()

        // THEN no charge is attempted and the customer is offered a restore
        XCTAssertTrue(fixture.spy.purchasedPlans.isEmpty)
        XCTAssertEqual(sut.state.alert, .existingEntitlement)
    }

    func test_purchase_WHEN_successful_THEN_emitsTheTransaction() async {
        // GIVEN a purchase that will succeed
        let transaction = InAppTransactionStub(identifier: "txn-42")
        fixture.spy.purchaseResult = .success(transaction)
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN it completes
        sut.send(.purchaseTapped(source: .mainScreen))
        await fixture.settle()

        // THEN the host receives the very transaction the App Store returned
        guard case .didPurchase(let emitted)? = fixture.outputs.last else {
            return XCTFail("Expected didPurchase, got \(fixture.outputs)")
        }
        XCTAssertEqual(emitted.identifier, "txn-42")
    }

    func test_purchase_WHEN_transactionExpired_THEN_finishesItAndEmitsNoPurchase() async {
        // GIVEN an already-expired transaction
        fixture.spy.purchaseResult = .success(InAppTransactionStub(identifier: "txn-old", isExpired: true))
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN the purchase completes
        sut.send(.purchaseTapped(source: .mainScreen))
        await fixture.settle()

        // THEN it is finished exactly once so the App Store stops redelivering it
        XCTAssertEqual(fixture.spy.finishedTransactions, ["txn-old"])

        // AND no account creation is started
        XCTAssertFalse(fixture.outputs.contains { if case .didPurchase = $0 { return true } else { return false } })

        // AND the customer is told why nothing happened
        XCTAssertTrue(fixture.outputs.contains { if case .showWarning = $0 { return true } else { return false } })
    }

    func test_purchase_WHEN_tappedTwice_THEN_onlyChargesOnce() async {
        // GIVEN a ready store
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN the button is tapped twice in a row
        sut.send(.purchaseTapped(source: .mainScreen))
        sut.send(.purchaseTapped(source: .mainScreen))
        await fixture.settle()

        // THEN only one purchase reaches StoreKit
        XCTAssertEqual(fixture.spy.purchasedPlans, [.yearly])
    }

    // MARK: - Restore

    func test_restore_WHEN_successful_THEN_emitsTheAuthenticatedUser() async {
        // GIVEN a restorable subscription
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN restore runs
        sut.send(.restoreTapped)
        await fixture.settle()

        // THEN the host receives the signed-in account
        guard case .didAuthenticate(let user)? = fixture.outputs.last else {
            return XCTFail("Expected didAuthenticate, got \(fixture.outputs)")
        }
        XCTAssertEqual(user.credentials.username, "p0000000")
    }

    func test_restore_WHEN_nothingToRestore_THEN_showsTheEmptyAlert() async {
        // GIVEN an App Store account with no receipt
        fixture.spy.restoreResult = .failure(.nothingToRestore)
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN restore runs
        sut.send(.restoreTapped)
        await fixture.settle()

        // THEN the "no subscription found" alert appears
        XCTAssertEqual(sut.state.alert, .nothingToRestore)
    }

    /// A receipt that exists but cannot be signed in with is a different problem, and the design
    /// gives it different wording.
    func test_restore_WHEN_loginFails_THEN_showsTheRestoreFailedAlert() async {
        // GIVEN a receipt that cannot be exchanged for an account
        fixture.spy.restoreResult = .failure(.restoreLoginFailed)
        let sut = fixture.makeStore(state: Stub.readyState())

        // WHEN restore runs
        sut.send(.restoreTapped)
        await fixture.settle()

        // THEN the other alert appears
        XCTAssertEqual(sut.state.alert, .restoreFailed)
    }

    // MARK: - Lifecycle

    func test_cancelAll_THEN_inFlightWorkStopsReportingBack() async {
        // GIVEN a store with a purchase in flight
        let sut = fixture.makeStore(state: Stub.readyState())
        sut.send(.purchaseTapped(source: .mainScreen))

        // WHEN the paywall disappears before it completes
        sut.cancelAll()
        await fixture.settle()

        // THEN nothing is emitted to a host that is no longer listening
        XCTAssertTrue(fixture.outputs.isEmpty)
    }
}
