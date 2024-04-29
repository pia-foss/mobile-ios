//
//  SignupPresentableErrorMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 1/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class SignupPresentableErrorMapper {
    func map(error: Error) -> String? {
        guard let purchaseProductsError = error as? PurchaseProductsError else {
            return ""
        }
        
        switch purchaseProductsError {
            case .generic:
                return "generic"
            case .productNotFound:
                return "productNotFound"
            case .uncreditedTransaction:
                return "uncreditedTransaction"
        }
    }
}
