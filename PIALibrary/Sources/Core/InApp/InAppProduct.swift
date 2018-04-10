//
//  InAppProduct.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Wraps any native implementation of an in-app product by providing a common interface.
public protocol InAppProduct: class, CustomStringConvertible {

    /// The product identifier.
    var identifier: String { get }
    
    /// The price of the product (localized).
    var price: NSNumber { get }

    /// The `Locale` in which `price` is expressed.
    var priceLocale: Locale { get }
    
    /// The underlying native product implementation.
    var native: Any? { get }
}

extension InAppProduct {
    var description: String {
        return "{\(identifier) @ \(priceLocale.currencySymbol ?? "")\(price)}"
    }
}
