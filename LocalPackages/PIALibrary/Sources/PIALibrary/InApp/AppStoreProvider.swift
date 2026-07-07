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
            let transaction = result.unsafePayloadValue
            if newest == nil || transaction.purchaseDate > newest!.date {
                if let jws = JWS(result.jwsRepresentation) {
                    newest = (transaction.purchaseDate, jws)
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
        log.debug("Start observing transactions")

        transactionObserverTask = Task {
            for await result in Transaction.updates {
                log.debug("transaction result: \(result)")
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
            return .failure(error)
        } catch {
            log.warning("returning unknown error from Product.products(for:): \(error)")
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

        availableProducts = result
        return .success(result)
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
            return .failure(.userCancelled)
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

        log.debug("Finishing transaction: \(native.id)")
        Task { await native.finish() }
    }
}
