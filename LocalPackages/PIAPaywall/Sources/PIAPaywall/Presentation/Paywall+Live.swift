//
//  Paywall+Live.swift
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
import PIABase
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: Paywall.Dependencies.self)

// The only file in PIAPaywall that touches `Client`. Everything above this line is testable without
// a `Client` stack; everything here is the thin adapter onto PIALibrary.
public extension Paywall.Dependencies {

    /// `@MainActor` because `AccountProvider` and `InAppProvider` are not `Sendable`: pinning the
    /// adapter to one actor is what allows them to be captured by the dependency closures at all.
    @MainActor
    static func live(
        accountProvider: AccountProvider,
        store: InAppProvider,
        emit: @escaping @MainActor (Paywall.Output) -> Void
    ) -> Paywall.Dependencies {
        Paywall.Dependencies(
            loadOffers: {
                switch await accountProvider.listPlanProducts() {
                case .failure:
                    return .failure(.productsUnavailable)

                case .success(let products):
                    let offers = makeOffers(from: products)
                    guard !offers.isEmpty else { return .failure(.productsUnavailable) }
                    var trialOffer: PaywallTrialOffer? = nil
                    if let product = products[.yearly] ?? products[.monthly] {
                        let days = await store.eligibleDaysForIntroOffer(for: product)
                        trialOffer = PaywallTrialOffer(days: days)
                    }
                    return .success(OffersPayload(offers: offers, trialOffer: trialOffer))
                }
            },

            hasExistingEntitlement: {
                await store.currentEntitlementJWS() != nil
            },

            purchase: { request in
                let result: Result<any InAppTransaction, ClientError>
                switch request {
                case .plan(let plan):
                    result = await accountProvider.purchase(plan: plan.libraryPlan)
                case .product(let product):
                    result = await accountProvider.purchase(product: product)
                }
                switch result {
                case .success(let transaction):
                    return .success(transaction)
                case .failure(let error):
                    return .failure(map(error))
                }
            },

            finishTransaction: { transaction in
                await transaction.finish()
            },

            restore: {
                switch await accountProvider.restorePurchases() {
                case .failure:
                    // No receipt at all. Distinct from finding one that cannot be signed in with,
                    // because the two produce different alerts.
                    return .failure(.nothingToRestore)

                case .success(let jws):
                    return await loginWithReceipt(jws, accountProvider: accountProvider)
                }
            },

            purchaseIntents: {
                AsyncStream { continuation in
                    let observer = PurchaseIntentObserver()
                    observer.start()
                    // The observer is held by this task alone, so `onTermination` needs to capture
                    // nothing but the task — which is what keeps a non-`Sendable` type out of a
                    // `@Sendable` closure.
                    let task = Task { @MainActor in
                        for await product in observer.purchaseIntents {
                            log.debug("Purchase intent received for product id: \(product.identifier)")
                            guard let product = product as? AppStoreProduct else { continue }
                            continuation.yield(product)
                        }
                        observer.stop()
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            },

            emit: emit
        )
    }

    // MARK: - Mapping

    /// Formats each product once, while the StoreKit product and its locale are still in scope.
    private static func makeOffers(from products: [Plan: any InAppProduct]) -> [PaywallPlanID: PaywallOffer] {
        var offers: [PaywallPlanID: PaywallOffer] = [:]
        for id in PaywallPlanID.allCases {
            guard let product = products[id.libraryPlan] else { continue }
            let purchasePlan = PurchasePlan(plan: id.libraryPlan, product: product, monthlyFactor: id.monthlyFactor)
            offers[id] = PaywallOffer(
                id: id,
                priceString: purchasePlan.priceString,
                monthlyPriceString: purchasePlan.monthlyPriceString,
                accessibleMonthlyPriceString: purchasePlan.accessibleMonthlyPriceString
            )
        }
        return offers
    }

    /// `ClientError` carries no usable message of its own (see `PaywallError`), so every case is
    /// mapped to an explicit localized string here.
    private static func map(_ error: ClientError) -> PaywallError {
        switch error {
        case .userCancelled:
            return .userCancelled
        case .purchasePending:
            return .purchasePending
        case .sandboxPurchase:
            return .failed(message: L10n.Signup.Failure.Purchase.Sandbox.message)
        case .productUnavailable:
            return .productsUnavailable
        default:
            return .failed(message: L10n.Signup.Paywall.Error.purchaseFailed)
        }
    }

    /// `AccountProvider.login(with:)` is still callback-based, so it is bridged here — the same
    /// pattern the tvOS signup use cases already follow.
    private static func loginWithReceipt(
        _ jws: JWS,
        accountProvider: AccountProvider
    ) async -> Result<UserAccount, PaywallError> {
        await withCheckedContinuation { continuation in
            accountProvider.login(with: LoginReceiptRequest(receipt: jws)) { user, error in
                if let user, error == nil {
                    continuation.resume(returning: .success(user))
                } else {
                    continuation.resume(returning: .failure(.restoreLoginFailed))
                }
            }
        }
    }
}
