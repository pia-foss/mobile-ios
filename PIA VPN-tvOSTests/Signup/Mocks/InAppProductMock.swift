//
//  InAppProductMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 18/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

struct InAppProductMock: InAppProduct {
    enum Native: Equatable, Sendable { case none }

    let identifier: String
    let price: Decimal
    let priceLocale: Locale
    let native: Native
    let hasIntroOffer: Bool = false
    let description: String

    init(identifier: String, price: Decimal, priceLocale: Locale, native: Native, description: String) {
        self.identifier = identifier
        self.price = price
        self.priceLocale = priceLocale
        self.native = native
        self.description = description
    }
}
