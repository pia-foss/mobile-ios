//
//  DecoratorPurchaseProductsProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 24/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

extension SubscriptionOption {
    func toPlan() -> Plan {
        switch self {
            case .monthly:
                return .monthly
            case .yearly:
                return .yearly
        }
    }
}

class DecoratorPurchaseProductsProvider: PurchaseProductsProviderType {
    private let purchaseProductsProvider: PurchaseProductsAccountProviderType
    private let errorMapper: PurchaseProductDomainErrorMapper
    private let store: InAppProvider
    
    init(purchaseProductsProvider: PurchaseProductsAccountProviderType, errorMapper: PurchaseProductDomainErrorMapper, store: InAppProvider) {
        self.purchaseProductsProvider = purchaseProductsProvider
        self.errorMapper = errorMapper
        self.store = store
    }
    
    func purchase(subscriptionOption: SubscriptionOption, _ callback: @escaping (Result<InAppTransaction, PurchaseProductsError>) -> Void) {
        purchaseProductsProvider.purchase(plan: subscriptionOption.toPlan()) { [weak self] transaction, error in
            guard let self = self else { return }
            
            guard error == nil else {
                callback(.failure(errorMapper.map(error: error)))
                return
            }
            
            guard let transaction = transaction else {
                callback(.failure(errorMapper.map(error: error)))
                return
            }
            
            callback(.success(transaction))
        }
    }
}
