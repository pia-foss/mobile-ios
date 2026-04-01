//
//  PurchaseProductDomainErrorMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 24/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import StoreKit

class PurchaseProductDomainErrorMapper {
    func map(error: Error?) -> PurchaseProductsError {
        if let purchaseProductsError = error as? PurchaseProductsError {
            return purchaseProductsError
        }

        if let transactionError = error as? SKError {
            guard transactionError.code != .paymentCancelled else {
                return .paymentCancelled
            }

            return .other(message: transactionError.localizedDescription)
        }

        if error as? ClientError == ClientError.productUnavailable {
            return .productNotFound
        }

        return .generic
    }
}
