//
//  HasActiveSubscriptionUseCase.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol HasActiveSubscriptionUseCaseType {
    func callAsFunction() async -> Bool
}

/// Whether this Apple ID already holds a live subscription, so the paywall can offer welcome-back.
class HasActiveSubscriptionUseCase: HasActiveSubscriptionUseCaseType {
    private let paymentProvider: PaymentProviderType

    init(paymentProvider: PaymentProviderType) {
        self.paymentProvider = paymentProvider
    }

    func callAsFunction() async -> Bool {
        await paymentProvider.currentPaymentReceipt() != nil
    }
}
