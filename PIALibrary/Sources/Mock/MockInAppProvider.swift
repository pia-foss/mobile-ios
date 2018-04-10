//
//  MockInAppProvider.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

#if os(iOS)
private class MockProduct: InAppProduct {
    let identifier: String
    
    let price: NSNumber

    let priceLocale = Locale.current

    let native: Any? = nil
    
    init(_ identifier: String, _ price: NSNumber) {
        self.identifier = identifier
        self.price = price
    }
}

private class MockTransaction: InAppTransaction {
    let identifier: String? = "1234567890"
    
    let native: Any? = nil
}

class MockInAppProvider: InAppProvider, ConfigurationAccess {
    var availableProducts: [InAppProduct]?

    var paymentReceipt: Data? = Data()
    
    var hasUncreditedTransactions: Bool {
        return false
    }
    
    func startObservingTransactions() {
    }
    
    func stopObservingTransactions() {
    }
    
    func fetchProducts(identifiers: [String], _ callback: (([InAppProduct]?, Error?) -> Void)?) {
        availableProducts = []
        for (i, identifier) in accessedConfiguration.allProductIdentifiers().enumerated() {
            let price = (Double(i + 1) * 50.0) as NSNumber
            availableProducts?.append(MockProduct(identifier, price))
        }
        callback?(availableProducts, nil)
        Macros.postNotification(.__InAppDidFetchProducts, [
            .products: availableProducts!
        ])
    }
    
    func purchaseProduct(_ product: InAppProduct, _ callback: ((InAppTransaction?, Error?) -> Void)?) {
        callback?(MockTransaction(), nil)
    }
    
    func uncreditedTransaction(for product: InAppProduct) -> InAppTransaction? {
        return nil
    }
    
    func finishTransaction(_ transaction: InAppTransaction, success: Bool) {
    }
    
    func refreshPaymentReceipt(_ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
}
#endif
