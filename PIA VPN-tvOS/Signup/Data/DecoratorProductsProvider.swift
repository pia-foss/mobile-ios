//
//  DecoratorProductsProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

final class DecoratorProductsProvider: ProductsProviderType {
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

    func listPlanProducts(_ callback: (([Plan: InAppProduct]?, Error?) -> Void)?) {
        setupProducts { [weak self] in
            self?.decoratee.listPlanProducts(callback)
        }
    }

    private func setupProducts(completion: @escaping () -> Void) {
        subscriptionInformationProvider.subscriptionInformation { [weak self] info, error in
            if error != nil {
                self?.productConfiguration.setDefaultPlanProducts()
            }

            if let info {
                var plans: [String: Plan] = [:]
                for product in info.products where !product.legacy {
                    plans[product.identifier] = product.plan
                }
                self?.productConfiguration.setPlans(plans)
            }

            self?.store.startObservingTransactions()
            completion()
        }
    }
}
