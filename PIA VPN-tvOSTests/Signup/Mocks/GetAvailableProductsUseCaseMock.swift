//
//  GetAvailableProductsUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class GetAvailableProductsUseCaseMock: GetAvailableProductsUseCaseType {
    private let result: Result<[SubscriptionProduct], Error>
    
    init(result: Result<[SubscriptionProduct], Error>) {
        self.result = result
    }
    
    func getAllProducts() async throws -> [SubscriptionProduct] {
        switch result {
            case .success(let products):
                return products
            case .failure(let error):
                throw error
        }
    }
    
    func getProduct(productId: String) async throws -> SubscriptionProduct? {
        switch result {
            case .success(let products):
                return products.first
            case .failure(let error):
                throw error
        }
    }
}
