//
//  PurchaseProductsError.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 24/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum PurchaseProductsError: Error {
    case generic
    case productNotFound
    case uncreditedTransaction
}
