//
//  AppStoreTransaction.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import StoreKit

class AppStoreTransaction: InAppTransaction {
    var identifier: String? {
        return nativeTransaction.transactionIdentifier
    }
    
    let native: Any?
    
    private var nativeTransaction: SKPaymentTransaction {
        return native as! SKPaymentTransaction
    }
    
    init(native: SKPaymentTransaction) {
        self.native = native
    }
}
