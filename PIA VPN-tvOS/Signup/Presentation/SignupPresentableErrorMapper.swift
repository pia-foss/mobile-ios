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
        if let purchaseProductsError = error as? PurchaseProductsError {
            return mapPurchaseProductsError(error: purchaseProductsError)
        }
        
        return L10n.Localizable.Tvos.Signup.Subscription.Error.Message.generic
    }
    
    private func mapPurchaseProductsError(error: PurchaseProductsError) -> String? {
        switch error {
            case .uncreditedTransaction:
                return L10n.Signup.Purchase.Uncredited.Alert.message
            case .paymentCancelled:
                return L10n.Localizable.Tvos.Signup.Subscription.Error.Message.paymentCancelled
            case .other(message: let message):
                return message
            default:
                return L10n.Localizable.Tvos.Signup.Subscription.Error.Message.generic
        }
    }
}
