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
import StoreKit

private let log = PIALogger.logger(for: AppStoreProvider.self)

final class AppStoreProvider: NSObject, InAppProvider {
    private var receiptRefreshRequest: SKReceiptRefreshRequest?

    private var receiptCallbacks: [SuccessLibraryCallback] = []

    private var transactionObserverTask: Task<Void, Never>?

    deinit {
        transactionObserverTask?.cancel()
        transactionObserverTask = nil
    }

    // MARK: InAppProvider

    private(set) var availableProducts: [any InAppProduct]?

    var paymentReceipt: Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        do {
            let contents = try Data(contentsOf: url)
            log.debug("Returning receipt with \(contents.count) bytes.")
            return contents
        } catch {
            log.debug("Failed to read contents of appStoreReceiptURL")
            return nil
        }
    }

    func startObservingTransactions() {
        log.debug("Start observing transactions")

        transactionObserverTask = Task {
            for await result in Transaction.updates {
                log.debug("transaction result: \(result)º")
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
        let products: [StoreKit.Product]
        do {
            products = try await StoreKit.Product.products(for: identifiers)
        } catch let error as StoreKitError {
            return .failure(error)
        } catch {
            log.warning("returning unknown error from Product.products(for:): \(error)")
            return .failure(.unknown)
        }

        // TODO: resolve hasIntroOffer
        let result = products.map { AppStoreProduct(native: $0, hasIntroOffer: false) }
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

        guard let product = product.native as? StoreKit.Product else {
            log.error("Product is not a StoreKit.Product: \(product)")
            return .failure(.invalidParameter)
        }

        log.debug("Purchasing product with identifier: \(product.id)")
        let result: StoreKit.Product.PurchaseResult
        do {
            result = try await product.purchase()
        } catch {
            return .failure(.unknown(code: 606, message: error.localizedDescription))
        }

        switch result {
        case .success(.verified(let transaction)):
            log.debug("\(#function) success verified")
            return .success(AppStoreTransaction(native: transaction))
        case .success(.unverified(let transaction, let error)):
            log.debug("\(#function) success unverified")
            log.warning("Unverified transaction: \(error)")
            return .success(AppStoreTransaction(native: transaction))
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
        guard let transaction = transaction.native as? SKPaymentTransaction else {
            log.error("Native transaction must be SKPaymentTransaction, but got \(type(of: transaction.native))")
            return
        }

        finishTransaction(transaction, success: success)
    }

    func finishTransaction(_ transaction: SKPaymentTransaction?, success: Bool) {
        guard let transaction else {
            log.error("finishTransaction called with nil transaction")
            return
        }

        if success {
            log.debug("Finishing successful transaction: \(transaction)")
        } else {
            log.debug("Finishing failed/cancelled transaction: \(transaction)")
        }

        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func refreshPaymentReceipt(_ callback: SuccessLibraryCallback?) {
        log.debug("Refreshing local copy of payment receipt...")

        if let callback {
            receiptCallbacks.append(callback)
        }

        // Coalesce: if a refresh is already in flight, the in-flight request will
        // fire every queued callback when it finishes.
        guard receiptRefreshRequest == nil else { return }

        receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
        receiptRefreshRequest?.delegate = self
        receiptRefreshRequest?.start()
    }
}

extension AppStoreProvider: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        guard (request == receiptRefreshRequest) else {
            return
        }
        receiptRefreshRequest = nil
        log.debug("Finished refreshing payment receipt")
        let callbacks = receiptCallbacks
        receiptCallbacks.removeAll()
        callbacks.forEach { $0(nil) }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard (request == receiptRefreshRequest) else {
            return
        }
        receiptRefreshRequest = nil
        log.error("Failed to refresh payment receipt (error: \(error))")
        let callbacks = receiptCallbacks
        receiptCallbacks.removeAll()
        callbacks.forEach { $0(error) }
    }
}

/// :nodoc:
extension SKProduct {
    open override var description: String {
        return productIdentifier
    }
}

/// :nodoc:
extension SKPaymentTransaction {
    open override var description: String {
        return "{'\(transactionIdentifier ?? "")' -> \(payment.productIdentifier)}"
    }
}
