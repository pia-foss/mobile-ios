//
//  PurchaseIntentObserver.swift
//  PIALibrary
//
//  Created by Mario on 16/07/26.
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

private let log = PIALogger.logger(for: PurchaseIntentObserver.self)

/// Observes purchases initiated outside the app (e.g. from the App Store product page)
/// and emits the purchased product for the caller to handle.
///
/// Uses `PurchaseIntent.intents` on iOS 16.4+, falling back to
/// `SKPaymentTransactionObserver.paymentQueue(_:shouldAddStorePayment:for:)` on iOS 15-16.3.
public final class PurchaseIntentObserver: NSObject, SKPaymentTransactionObserver {
    public let purchaseIntents: AsyncStream<any InAppProduct>
    private let continuation: AsyncStream<any InAppProduct>.Continuation
    private var observeTask: Task<Void, Never>?

    public override init() {
        var continuation: AsyncStream<any InAppProduct>.Continuation!
        purchaseIntents = AsyncStream { continuation = $0 }
        self.continuation = continuation
        super.init()
    }

    public func start() {
        if #available(iOS 16.4, *) {
            observeTask = Task { [weak self] in
                for await purchaseIntent in PurchaseIntent.intents {
                    guard let self, !Task.isCancelled else {
                        self?.stop()
                        break
                    }
                    log.debug("Observed purchase intent for product: \(purchaseIntent.product.id)")
                    self.continuation.yield(AppStoreProduct(native: purchaseIntent.product, hasIntroOffer: false))
                }
            }
        } else {
            SKPaymentQueue.default().add(self)
        }
    }

    public func stop() {
        observeTask?.cancel()
        observeTask = nil
        SKPaymentQueue.default().remove(self)
        continuation.finish()
    }

    // MARK: SKPaymentTransactionObserver

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {}

    @available(iOS, deprecated: 16.4, message: "Superseded by PurchaseIntent.intents")
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        let identifier = product.productIdentifier
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let product = try await Product.products(for: [identifier]).first else {
                    log.warning("StoreKit 2 product not found for identifier: \(identifier)")
                    return
                }
                log.debug("Observed store payment for product: \(identifier)")
                self.continuation.yield(AppStoreProduct(native: product, hasIntroOffer: false))
            } catch {
                log.warning("Unable to find StoreKit 2 product with id \(identifier): \(error)")
            }
        }

        // we don't let StoreKit 1 handle the purchase; it's re-issued through StoreKit 2 above
        return false
    }
}
