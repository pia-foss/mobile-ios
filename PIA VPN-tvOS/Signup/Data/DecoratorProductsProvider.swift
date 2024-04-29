//
//  DecoratorProductsProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class DecoratorProductsProvider: ProductsProviderType {
    private let subscriptionInformationProvider: SubscriptionInformationProviderType
    private let decoratee: ProductsProviderType
    private let store: InAppProvider
    private let productConfiguration: ProductConfigurationType
    
    init(subscriptionInformationProvider: SubscriptionInformationProviderType, decoratee: ProductsProviderType, store: InAppProvider, productConfiguration: ProductConfigurationType) {
        self.subscriptionInformationProvider = subscriptionInformationProvider
        self.decoratee = decoratee
        self.store = store
        self.productConfiguration = productConfiguration
    }
    
    func listPlanProducts(_ callback: (([Plan : InAppProduct]?, Error?) -> Void)?) {
        setupProducts { [weak self] in
            self?.decoratee.listPlanProducts(callback)
        }
    }
    
    private func setupProducts(completion: @escaping () -> Void) {
        subscriptionInformationProvider.subscriptionInformation { [weak self] (info, error) in
            if let _ = error {
                self?.setDefaultPlanProducts()
            }
            
            if let info = info {
                for product in info.products where !product.legacy {
                    self?.productConfiguration.setPlan(product.plan, forProductIdentifier: product.identifier)
                }
            }
            
            self?.store.startObservingTransactions()
            completion()
        }
    }
        
    private func setDefaultPlanProducts() {
        productConfiguration.setPlan(.yearly, forProductIdentifier: AppConstants.InApp.yearlyProductIdentifier)
        productConfiguration.setPlan(.monthly, forProductIdentifier: AppConstants.InApp.monthlyProductIdentifier)
    }
}
