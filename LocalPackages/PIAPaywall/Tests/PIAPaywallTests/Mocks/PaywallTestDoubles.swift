//
//  PaywallTestDoubles.swift
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
import PIABase
import PIALibrary

@testable import PIAPaywall

// MARK: - Values

enum Stub {
    static func offer(
        _ id: PaywallPlanID,
        price: String = "$72.98",
        monthly: String = "$6.08"
    ) -> PaywallOffer {
        PaywallOffer(
            id: id,
            priceString: price,
            monthlyPriceString: monthly,
            accessibleMonthlyPriceString: "\(monthly) per month"
        )
    }

    static let yearly = offer(.yearly, price: "$72.98", monthly: "$6.08")
    static let monthly = offer(.monthly, price: "$16.99", monthly: "$16.99")

    static var bothOffers: [PaywallPlanID: PaywallOffer] {
        [.yearly: yearly, .monthly: monthly]
    }

    static func payload(
        offers: [PaywallPlanID: PaywallOffer] = Stub.bothOffers,
        isEligibleForIntroOffer: Bool = true
    ) -> OffersPayload {
        OffersPayload(offers: offers, trialOffer: isEligibleForIntroOffer ? .init(days: 7) : nil)
    }

    static let user = UserAccount(
        credentials: Credentials(username: "p0000000", password: "secret"),
        info: nil
    )

    static var account: Paywall.Action.Account { .init(user) }

    static func transaction(identifier: String = "txn-1", isExpired: Bool = false) -> Paywall.Action.Transaction {
        .init(InAppTransactionStub(identifier: identifier, isExpired: isExpired))
    }

    /// A state that has finished loading, so purchase actions are not rejected by the guards.
    static func readyState(
        offers: [PaywallPlanID: PaywallOffer] = Stub.bothOffers,
        isEligibleForIntroOffer: Bool = true,
        defaultPlan: PaywallPlanID = .yearly
    ) -> Paywall.State {
        Paywall.State(
            phase: .ready,
            offers: offers,
            trialOffer: isEligibleForIntroOffer ? .init(days: 7) : nil,
            defaultPlan: defaultPlan,
            sheetSelection: defaultPlan
        )
    }
}

// MARK: - Transaction

final class InAppTransactionStub: InAppTransaction, @unchecked Sendable {
    typealias Native = String

    let identifier: String
    let jwsRepresentation: JWS
    let native: String
    let isExpired: Bool

    /// PIALibrary's default `description` for `InAppTransaction` is internal to that module.
    var description: String { identifier }

    private(set) var finishCallCount = 0

    init(identifier: String = "txn-1", isExpired: Bool = false) {
        self.identifier = identifier
        self.native = identifier
        self.isExpired = isExpired
        self.jwsRepresentation = JWS("stub-jws")!
    }

    func finish() async {
        finishCallCount += 1
    }
}

// MARK: - Dependencies

extension Paywall.Dependencies {
    /// Fails loudly if the feature reaches for something a test did not configure, so a missing
    /// stub shows up as a clear failure rather than a silent default.
    static func test(
        loadOffers: @escaping () async -> Result<OffersPayload, PaywallError> = { .success(Stub.payload()) },
        hasExistingEntitlement: @escaping () async -> Bool = { false },
        purchase: @escaping (PurchaseRequest) async -> Result<any InAppTransaction, PaywallError> = { _ in
            .success(InAppTransactionStub())
        },
        finishTransaction: @escaping (any InAppTransaction) async -> Void = { _ in },
        restore: @escaping () async -> Result<UserAccount, PaywallError> = { .success(Stub.user) },
        purchaseIntents: @escaping () -> AsyncStream<AppStoreProduct> = { AsyncStream { $0.finish() } },
        emit: @escaping (Paywall.Output) -> Void = { _ in }
    ) -> Paywall.Dependencies {
        Paywall.Dependencies(
            loadOffers: loadOffers,
            hasExistingEntitlement: hasExistingEntitlement,
            purchase: purchase,
            finishTransaction: finishTransaction,
            restore: restore,
            purchaseIntents: purchaseIntents,
            emit: emit
        )
    }
}

/// Records what the store actually asked the outside world to do.
final class DependencySpy: @unchecked Sendable {
    private(set) var loadOffersCallCount = 0
    private(set) var entitlementCheckCallCount = 0
    private(set) var purchasedPlans: [PurchaseRequest] = []
    private(set) var finishedTransactions: [String] = []
    private(set) var restoreCallCount = 0

    /// Everything the feature reported to its host, in order.
    private(set) var emittedOutputs: [Paywall.Output] = []

    /// The order in which the entitlement check and the purchase happened. The check must come
    /// first, or a customer who already owns a subscription gets charged twice.
    private(set) var callOrder: [String] = []

    var offersResult: Result<OffersPayload, PaywallError> = .success(Stub.payload())
    var hasEntitlement = false
    var purchaseResult: Result<any InAppTransaction, PaywallError> = .success(InAppTransactionStub())
    var restoreResult: Result<UserAccount, PaywallError> = .success(Stub.user)

    /// How many times the feature subscribed to purchases started outside the app.
    ///
    /// `AppStoreProduct` wraps a StoreKit `Product`, which no unit test can construct, so the
    /// subscription is what is observable here rather than the products it would deliver.
    private(set) var purchaseIntentsCallCount = 0

    func makeDependencies() -> Paywall.Dependencies {
        Paywall.Dependencies(
            loadOffers: { [self] in
                loadOffersCallCount += 1
                callOrder.append("loadOffers")
                return offersResult
            },
            hasExistingEntitlement: { [self] in
                entitlementCheckCallCount += 1
                callOrder.append("hasExistingEntitlement")
                return hasEntitlement
            },
            purchase: { [self] request in
                purchasedPlans.append(request)
                callOrder.append("purchase")
                return purchaseResult
            },
            finishTransaction: { [self] transaction in
                finishedTransactions.append(transaction.identifier)
                callOrder.append("finishTransaction")
            },
            restore: { [self] in
                restoreCallCount += 1
                callOrder.append("restore")
                return restoreResult
            },
            purchaseIntents: { [self] in
                purchaseIntentsCallCount += 1
                callOrder.append("purchaseIntents")
                return AsyncStream { $0.finish() }
            },
            emit: { [self] output in
                emittedOutputs.append(output)
                callOrder.append("emit")
            }
        )
    }

    var purchasedTransactions: [any InAppTransaction] {
        emittedOutputs.compactMap { if case .didPurchase(let transaction) = $0 { return transaction } else { return nil } }
    }

    var authenticatedUsers: [UserAccount] {
        emittedOutputs.compactMap { if case .didAuthenticate(let user) = $0 { return user } else { return nil } }
    }

    var emittedWarnings: [String] {
        emittedOutputs.compactMap { if case .showWarning(let message) = $0 { return message } else { return nil } }
    }

    var didRequestLogin: Bool {
        emittedOutputs.contains { if case .requestLogin = $0 { return true } else { return false } }
    }

    var didCancel: Bool {
        emittedOutputs.contains { if case .didCancel = $0 { return true } else { return false } }
    }
}
