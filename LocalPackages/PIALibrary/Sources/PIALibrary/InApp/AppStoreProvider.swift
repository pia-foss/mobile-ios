//
//  AppStoreProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2020 Private Internet Access, Inc.
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
import StoreKit

private let log = PIALogger.logger(for: AppStoreProvider.self)

final class AppStoreProvider: NSObject, InAppProvider {
    private var transactionObserverTask: Task<Void, Never>?

    deinit {
        transactionObserverTask?.cancel()
        transactionObserverTask = nil
    }

    // MARK: InAppProvider

    private(set) var availableProducts: [any InAppProduct]?

    func currentEntitlementJWS() async -> JWS? {
        var newest: (date: Date, jws: JWS)?
        for await result in Transaction.currentEntitlements {
            switch result {
            case .unverified(let transaction, let error):
                log.warning("Ignoring unverified transaction: \(error)")
                await transaction.finish()
            case .verified(let transaction):
                if newest == nil || transaction.purchaseDate > newest!.date {
                    if let jws = JWS(result.jwsRepresentation) {
                        newest = (transaction.purchaseDate, jws)
                    }
                }
            }
        }
        if let jws = newest?.jws {
            return jws
        }
        log.debug("No current entitlements found")
        return nil
    }

    func synchronizeEntitlements() async -> Error? {
        log.debug("Synchronizing entitlements with the App Store...")
        do {
            try await AppStore.sync()
            return nil
        } catch {
            log.error("AppStore.sync() failed: \(error)")
            return error
        }
    }

    func startObservingTransactions() {
        log.debug("Start observing unfinished transactions")

        // On startup we check for unfinished transactions and finish them. With
        // our current architecture is difficult to handle them. Users can always
        // use the restore flow to claim transactions.
        transactionObserverTask = Task {
            for await result in Transaction.updates {
                if Task.isCancelled { break }
                switch result {
                case .unverified(let transaction, let error):
                    log.warning("Unverified transaction: \(transaction.id) \(error)")
                    log.debug("Finishing transaction: \(transaction.id)")
                    await transaction.finish()
                case .verified(let transaction):
                    log.debug("Finishing transaction: \(transaction.id)")
                    await transaction.finish()
                }
            }
        }
    }

    func stopObservingTransactions() {
        log.debug("Stop observing transactions")
        transactionObserverTask?.cancel()
        transactionObserverTask = nil
    }

    func fetchProducts(identifiers: Set<String>) async -> Result<[any InAppProduct], StoreKitError> {
        guard !identifiers.isEmpty else {
            log.debug("Skip fetching products for empty identifiers")
            return .success([])
        }

        log.debug("Requesting products: \(identifiers)")

        let products: [Product]
        do {
            products = try await Product.products(for: identifiers)
        } catch let error as StoreKitError {
            log.warning("Failed to fetch products from App Store: \(error)")
            return .failure(error)
        } catch {
            log.warning("Returning unknown error from Product.products(for:): \(error)")
            return .failure(.unknown)
        }

        var introOffers: [String: Bool] = [:]
        var result: [AppStoreProduct] = []
        for product in products {
            var hasIntroOffer: Bool = false
            if let subscription = product.subscription {
                if let has = introOffers[subscription.subscriptionGroupID] {
                    hasIntroOffer = has
                } else {
                    hasIntroOffer = await subscription.isEligibleForIntroOffer
                    introOffers[subscription.subscriptionGroupID] = hasIntroOffer
                }
            }
            let appStoreProduct = AppStoreProduct(native: product, hasIntroOffer: hasIntroOffer)
            result.append(appStoreProduct)
        }

        cacheAvailableProducts(result)
        return .success(result)
    }

    /// Stores freshly fetched products as the process-wide cache.
    ///
    /// An empty result is deliberately **not** cached. `availableProducts` would otherwise become a
    /// non-nil empty array, which makes `DefaultAccountProvider.planProducts` a non-nil empty
    /// dictionary, which makes `listPlanProducts()` serve that as a cache hit for the rest of the
    /// process — so a transient App Store hiccup would leave the app permanently without prices and
    /// any retry would be a no-op. Leaving the cache untouched keeps the next call re-requesting.
    func cacheAvailableProducts(_ products: [any InAppProduct]) {
        guard !products.isEmpty else {
            log.warning("App Store returned no products; keeping the existing cache so a retry can refetch")
            return
        }
        availableProducts = products
    }

    func isEligibleForIntroOffer(for product: any InAppProduct) async -> Bool {
        guard let native = product.native as? Product else {
            log.error("Product must be a StoreKit.Product, but got \(type(of: product.native))")
            return false
        }
        guard let subscription = native.subscription else {
            log.debug("Product \(native.id) is not a subscription, so it has no intro offer")
            return false
        }
        return await Product.SubscriptionInfo.isEligibleForIntroOffer(for: subscription.subscriptionGroupID)
    }

    func purchase(product: any InAppProduct) async -> Result<any InAppTransaction, ClientError> {
        guard product is AppStoreProduct else {
            log.error("Product must be AppStoreProduct, but got \(type(of: product))")
            return .failure(ClientError.productUnavailable)
        }

        if !Client.configuration.arePurchasesAvailable() {
            log.warning("Purchases not available in sandbox")
            return .failure(ClientError.sandboxPurchase)
        }

        guard let product = product.native as? Product else {
            log.error("Product is not a StoreKit.Product: \(product)")
            return .failure(.invalidParameter)
        }

        log.debug("Purchasing product with identifier: \(product.id)")
        let result: Product.PurchaseResult
        do {
            result = try await product.purchase()
        } catch {
            return .failure(.unknown(code: 606, message: error.localizedDescription))
        }

        switch result {
        case .success(let verification):
            guard let jws = JWS(verification.jwsRepresentation) else {
                log.error("Failed to create JWS from: \(verification.jwsRepresentation)")
                await verification.unsafePayloadValue.finish()
                return .failure(.badReceipt)
            }
            switch verification {
            case .verified(let transaction):
                log.debug("\(#function) success verified")
                return .success(AppStoreTransaction(native: transaction, jwsRepresentation: jws))
            case .unverified(let transaction, let error):
                log.debug("\(#function) success unverified")
                log.warning("Unverified transaction: \(error)")
                return .success(AppStoreTransaction(native: transaction, jwsRepresentation: jws))
            }
        case .userCancelled:
            log.debug("\(#function) userCancelled")
            return .failure(.userCancelled)
        case .pending:
            log.debug("\(#function) pending")
            return .failure(.purchasePending)
        @unknown default:
            log.warning("Unknown purchase result: \(result)")
            return .failure(.unknown(code: 606, message: "Unknown purchase result: \(result)"))
        }
    }

    func finishTransaction(_ transaction: any InAppTransaction, success: Bool) {
        guard let native = transaction.native as? Transaction else {
            log.error("Native transaction must be StoreKit.Transaction, but got \(type(of: transaction.native))")
            return
        }

        guard success else {
            // Leave the transaction unfinished so StoreKit keeps re-delivering it through
            // `Transaction.updates` until the content is successfully delivered to the backend.
            log.debug("Not finishing transaction \(native.id): delivery was not successful")
            return
        }

        log.debug("Finishing transaction: \(native.id)")
        Task { await native.finish() }
    }
}
