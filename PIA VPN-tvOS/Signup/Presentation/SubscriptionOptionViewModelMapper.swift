//
//  SubscriptionOptionViewModelMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIALocalizations

final class SubscriptionOptionViewModelMapper {
    func map(product: SubscriptionProduct) -> SubscriptionOptionViewModel {
        let isYearlyPlan = product.type == .yearly
        let optionString = isYearlyPlan ? L10n.Tiles.Subscription.yearly : L10n.Tiles.Subscription.monthly

        let locale = product.product.priceLocale
        let rawPrice = PurchasePlan.string(forPrice: product.product.price, locale: locale)
        let price =
            rawPrice + " "
            + (isYearlyPlan
                ? L10n.Tvos.Signup.Subscription.Paywall.Price.year
                : L10n.Welcome.Plan.Accessibility.perMonth)
        let monthlyPriceValue = NSDecimalNumber(value: product.product.price.doubleValue / 12)
        let monthlyPrice = PurchasePlan.string(forPrice: monthlyPriceValue, locale: locale) + L10n.Tvos.Signup.Subscription.Paywall.Price.Month.simplified

        return SubscriptionOptionViewModel(
            productId: product.product.identifier,
            option: product.type,
            optionString: optionString,
            price: price,
            rawPrice: rawPrice,
            monthlyPrice: isYearlyPlan ? monthlyPrice : nil,
            freeTrial: isYearlyPlan ? L10n.Tvos.Signup.Subscription.Paywall.Price.trial : nil)
    }
}
