//
//  SubscriptionOptionViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 5/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum SubscriptionOption: Int {
    case yearly, monthly
}

struct SubscriptionOptionViewModel {
    let productId: String
    let option: SubscriptionOption
    let optionString: String
    let price: String
    let rawPrice: String
    let monthlyPrice: String?
    let freeTrial: String?
}
