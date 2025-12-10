//
//  MockInAppProvider.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 10/22/17.
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

#if os(iOS) || os(tvOS)
@available(tvOS 17.0, *)
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

@available(tvOS 17.0, *)
private class MockTransaction: InAppTransaction {
    let identifier: String? = "1234567890"
    
    let native: Any? = nil
}

@available(tvOS 17.0, *)
class MockInAppProvider: InAppProvider, ConfigurationAccess {
    
    init(with receipt: Data? = Data()) {
        self.paymentReceipt = receipt
    }
    var availableProducts: [InAppProduct]?

    var paymentReceipt: Data?
    
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
