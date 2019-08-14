//
//  AppStoreProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class AppStoreProvider: NSObject, InAppProvider {
    private(set) var uncreditedTransactions: [InAppTransaction]
    
    private var productsRequest: SKProductsRequest?

    private var receiptRefreshRequest: SKReceiptRefreshRequest?

    private var productsCallback: LibraryCallback<[InAppProduct]>?

    private var purchaseCallback: LibraryCallback<InAppTransaction>?

    private var receiptCallback: SuccessLibraryCallback?

    override init() {
        uncreditedTransactions = []
        super.init()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: InAppProvider

    private(set) var availableProducts: [InAppProduct]?

    var paymentReceipt: Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    var hasUncreditedTransactions: Bool {
        return !uncreditedTransactions.isEmpty
    }

    func startObservingTransactions() {
        log.debug("Start observing transactions")
        
        SKPaymentQueue.default().add(self)
    }
    
    func stopObservingTransactions() {
        log.debug("Stop observing transactions")
        
        SKPaymentQueue.default().remove(self)
    }
    
    func fetchProducts(identifiers: [String], _ callback: (([InAppProduct]?, Error?) -> Void)?) {
        guard !identifiers.isEmpty else {
            callback?([], nil)
            return
        }

        log.debug("Requesting products: \(identifiers)")

        productsCallback = callback
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    func purchaseProduct(_ product: InAppProduct, _ callback: ((InAppTransaction?, Error?) -> Void)?) {
        guard product is AppStoreProduct else {
            fatalError("Product must be AppStoreProduct")
        }
        guard (purchaseCallback == nil) else {
            log.warning("Purchase in progress")
            return
        }
        if !Client.configuration.arePurchasesAvailable() {
            log.warning("Purchases not available in sandbox")
            callback?(nil, ClientError.sandboxPurchase)
            return
        }
        let payment = SKPayment(product: product.native as! SKProduct)
        log.debug("Purchasing product with identifier: \(payment.productIdentifier)")

        purchaseCallback = callback
        SKPaymentQueue.default().add(payment)
    }
    
    func uncreditedTransaction(for product: InAppProduct) -> InAppTransaction? {
        guard product is AppStoreProduct else {
            fatalError("Product must be AppStoreProduct")
        }
        for uncredited in uncreditedTransactions {
            let nativeTransaction = uncredited.native as! SKPaymentTransaction
            let nativeProduct = product.native as! SKProduct
            if (nativeTransaction.payment.productIdentifier == nativeProduct.productIdentifier) {
                return uncredited
            }
        }
        return nil
    }

    func finishTransaction(_ transaction: InAppTransaction, success: Bool) {
        guard transaction is AppStoreTransaction else {
            fatalError("Transaction must be AppStoreTransaction")
        }
        finishAndRemoveTransaction(transaction.native as! SKPaymentTransaction, success: success)
    }

    func refreshPaymentReceipt(_ callback: SuccessLibraryCallback?) {
        log.debug("Refreshing local copy of payment receipt...")

        receiptCallback = callback
        receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
        receiptRefreshRequest?.delegate = self
        receiptRefreshRequest?.start()
    }
    
    // MARK: Helpers

    private func addUncreditedTransaction(_ transaction: SKPaymentTransaction) {
        log.debug("Adding uncredited transaction: \(transaction)")
        uncreditedTransactions.append(AppStoreTransaction(native: transaction))
        
        log.debug("Uncredited transactions now: \(uncreditedTransactions)")

        Macros.postNotification(.__InAppDidAddUncredited)
    }
    
    private func removeUncreditedTransaction(_ transactionToRemove: SKPaymentTransaction) {
        log.debug("Removing uncredited transaction: \(transactionToRemove)")
        
        for (i, transaction) in uncreditedTransactions.enumerated() {
            if (transaction.native as? SKPaymentTransaction == transactionToRemove) {
                uncreditedTransactions.remove(at: i)
                break
            }
        }
        
        log.debug("Uncredited transactions now: \(uncreditedTransactions)")
    }

    private func finishAndRemoveTransaction(_ transaction: SKPaymentTransaction, success: Bool) {
        if success {
            log.debug("Finishing successful transaction: \(transaction)")
        } else {
            log.debug("Finishing failed/cancelled transaction: \(transaction)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        removeUncreditedTransaction(transaction)
    }
}

extension AppStoreProvider: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard (request == productsRequest) else {
            return
        }
        productsRequest = nil
        log.debug("Retrieved products: \(response.products)")

        var availableProducts = [InAppProduct]()
        for product in response.products {
            log.debug("  -> \(product.localizedTitle) @ \(product.price)")
            availableProducts.append(AppStoreProduct(native: product))
        }
        self.availableProducts = availableProducts

        productsCallback?(availableProducts, nil)
        productsCallback = nil
    }
}

extension AppStoreProvider: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        log.debug("Transactions updated: \(transactions)")

        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break

            case .purchased:
                log.debug("  -> Purchased: \(transaction)")

                addUncreditedTransaction(transaction)
                purchaseCallback?(AppStoreTransaction(native: transaction), nil)
                purchaseCallback = nil

            case .deferred:
                log.debug("  -> Deferred: \(transaction)")

//                #warning TODO: Amir, implement and test Ask to Buy
//                NSError *error = [[NSError alloc] initWithDomain:ErrorDomain
//                code:ErrorCodeAskToBuy
//                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedXXXXString(@"Your payment requires approval.", @"payment transaction deferred message (Ask to Buy enabled)")}];
//
//                Macros.postNotification(.StoreDidFailToPurchase, error)

            case .restored:
                // not applicable for non-renewable subscriptions
                break

            case .failed:
                if let error = transaction.error {
                    log.error("Failed transaction: \(transaction) (error: \(error))")
                } else {
                    log.warning("Transaction was cancelled")
                }

                finishAndRemoveTransaction(transaction, success: false)

                if let error = transaction.error as? SKError, (error.code == .paymentCancelled) {
                    purchaseCallback?(nil, nil)
                } else {
                    purchaseCallback?(nil, transaction.error)
                }
                purchaseCallback = nil
            }
        }
    }
}

extension AppStoreProvider: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        guard (request == receiptRefreshRequest) else {
            return
        }
        receiptRefreshRequest = nil
        log.debug("Finished refreshing payment receipt")
        receiptCallback?(nil)
        receiptCallback = nil
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard (request == receiptRefreshRequest) else {
            return
        }
        receiptRefreshRequest = nil
        log.error("Failed to refresh payment receipt (error: \(error))")
        receiptCallback?(error)
        receiptCallback = nil
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
