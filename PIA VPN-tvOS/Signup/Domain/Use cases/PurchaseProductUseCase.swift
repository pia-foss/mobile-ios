//
//  PurchaseProductUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol PurchaseProductUseCaseType {
    func callAsFunction(subscriptionOption: SubscriptionOption) async throws -> InAppTransaction
}

class PurchaseProductUseCase: PurchaseProductUseCaseType {
    private let purchaseProductsProvider: PurchaseProductsProviderType
    
    init(purchaseProductsProvider: PurchaseProductsProviderType) {
        self.purchaseProductsProvider = purchaseProductsProvider
    }
    
    func callAsFunction(subscriptionOption: SubscriptionOption) async throws -> InAppTransaction {
        return try await withCheckedThrowingContinuation { continuation in
            purchaseProductsProvider.purchase(subscriptionOption: subscriptionOption) { result in
                switch result {
                case .success(let transaction):
                    continuation.resume(returning: transaction)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
