//
//  SubscriptionInformationProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 20/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SubscriptionInformationProvider: SubscriptionInformationProviderType {
    private let accountProvider: AccountProvider
    
    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    func subscriptionInformation(_ callback: @escaping (AppStoreInformation?, Error?) -> Void) {
        accountProvider.subscriptionInformation { appStoreInfo, error in
            guard let appStoreInfo = appStoreInfo else {
                callback(nil, error)
                return
            }
            
            let products = appStoreInfo.products.map { Product(identifier: $0.identifier, plan: $0.plan, price: $0.price, legacy: $0.legacy) }
            
            callback(AppStoreInformation(products: products, eligibleForTrial: appStoreInfo.eligibleForTrial), error)
        }
    }
}
