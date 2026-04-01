//
//  GetAvailableProductsUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 7/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol GetAvailableProductsUseCaseType {
    func getAllProducts() async throws -> [SubscriptionProduct]
    func getProduct(productId: String) async throws -> SubscriptionProduct?
}

class GetAvailableProductsUseCase: GetAvailableProductsUseCaseType {
    private let productsProvider: ProductsProviderType
    
    init(productsProvider: ProductsProviderType) {
        self.productsProvider = productsProvider
    }
    
    func getAllProducts() async throws -> [SubscriptionProduct] {
        return try await withCheckedThrowingContinuation { continuation in
            productsProvider.listPlanProducts { products, error in
                
                guard let products = products else {
                    continuation.resume(throwing: error == nil ? SubscriptionProductsError.noProducts : SubscriptionProductsError.generic)
                    return
                }
                
                var subscriptionProducts = [SubscriptionProduct]()
                products.forEach { product in
                    switch product.key {
                        case .monthly:
                            subscriptionProducts.append(SubscriptionProduct(product: product.value, type: .monthly))
                        case .yearly:
                            subscriptionProducts.append(SubscriptionProduct(product: product.value, type: .yearly))
                        default:
                            break
                    }
                }
                
                continuation.resume(returning: subscriptionProducts)
            }
        }
    }
    
    func getProduct(productId: String) async throws -> SubscriptionProduct? {
        let products = try await getAllProducts()
        return products.first { $0.product.identifier == productId }
    }
}
