//
//  InAppProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol InAppProvider: class {
    var availableProducts: [InAppProduct]? { get }
    
    var paymentReceipt: Data? { get }
    
    var hasUncreditedTransactions: Bool { get }
    
    func startObservingTransactions()
    
    func stopObservingTransactions()
    
    func fetchProducts(identifiers: [String], _ callback: LibraryCallback<[InAppProduct]>?)
    
    func purchaseProduct(_ product: InAppProduct, _ callback: LibraryCallback<InAppTransaction>?)
    
    func uncreditedTransaction(for product: InAppProduct) -> InAppTransaction?
    
    func finishTransaction(_ transaction: InAppTransaction, success: Bool)
    
    func refreshPaymentReceipt(_ callback: SuccessLibraryCallback?)
}
