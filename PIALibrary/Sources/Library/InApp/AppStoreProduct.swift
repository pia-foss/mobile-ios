//
//  AppStoreProduct.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import StoreKit

class AppStoreProduct: InAppProduct {
    var identifier: String {
        return nativeProduct.productIdentifier
    }
    
    var price: NSNumber {
        return nativeProduct.price
    }
    
    var priceLocale: Locale {
        return nativeProduct.priceLocale
    }
    
    let native: Any?
    
    private var nativeProduct: SKProduct {
        return native as! SKProduct
    }
    
    init(native: SKProduct) {
        self.native = native
    }
}
