//
//  InAppProductMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 18/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class InAppProductMock: InAppProduct {
    let identifier: String
    let price: NSNumber
    let priceLocale: Locale
    let native: Any?
    var description: String
    
    init(identifier: String, price: NSNumber, priceLocale: Locale, native: Any?, description: String) {
        self.identifier = identifier
        self.price = price
        self.priceLocale = priceLocale
        self.native = native
        self.description = description
    }
}
