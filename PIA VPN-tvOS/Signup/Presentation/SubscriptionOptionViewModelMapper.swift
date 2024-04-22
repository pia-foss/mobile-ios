//
//  SubscriptionOptionViewModelMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class SubscriptionOptionViewModelMapper {
    func map(product: SubscriptionProduct) -> SubscriptionOptionViewModel {
        let isYearlyPlan = product.type == .yearly
        let optionString = isYearlyPlan ? L10n.Localizable.Tiles.Subscription.yearly : L10n.Localizable.Tiles.Subscription.monthly
        
        let currency = "\(product.product.priceLocale.currencySymbol ?? "$")"
        let price = product.product.price.stringValue + currency  + " "
        + (isYearlyPlan ? L10n.Localizable.Tvos.Signup.Subscription.Paywall.Price.year
           : L10n.Localizable.Tvos.Signup.Subscription.Paywall.Price.month)
        let monthlyPrice = (monthlyPrice(price: product.product.price.doubleValue) ?? "") + currency +  L10n.Localizable.Tvos.Signup.Subscription.Paywall.Price.Month.simplified
        
        return SubscriptionOptionViewModel(productId: product.product.identifier,
                                           option: product.type,
                                           optionString: optionString,
                                           price: price,
                                           monthlyPrice: isYearlyPlan ? monthlyPrice : nil,
                                           freeTrial: isYearlyPlan ? L10n.Localizable.Tvos.Signup.Subscription.Paywall.Price.trial : nil)
    }
    
    private func monthlyPrice(price: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingMode = .halfUp

        return formatter.string(from: NSNumber(value: price / 12))
    }
}
