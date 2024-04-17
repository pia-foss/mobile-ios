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
    func getProducts(productId: String?) async throws -> SubscriptionProduct?
}

class GetAvailableProductsUseCase: GetAvailableProductsUseCaseType {
    func getAllProducts() async throws -> [SubscriptionProduct] { [] }
    func getProducts(productId: String?) async throws -> SubscriptionProduct? { nil }
}



