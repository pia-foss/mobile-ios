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
    case paymentCancelled
    case other(message: String)
}

extension PurchaseProductsError: Equatable {
    static func ==(lhs: PurchaseProductsError, rhs: PurchaseProductsError) -> Bool {
        switch (lhs, rhs) {
        case (.generic, .generic), (.productNotFound, .productNotFound), (.uncreditedTransaction, .uncreditedTransaction), (.paymentCancelled, .paymentCancelled):
            return true
        case (.other(let lhsMessage), .other(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
