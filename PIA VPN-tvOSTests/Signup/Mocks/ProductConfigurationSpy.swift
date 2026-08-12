//
//  ProductConfigurationSpy.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

@testable import PIA_VPN_tvOS

final class ProductConfigurationSpy: ProductConfigurationType {
    var setPlanCalledAttempt = 0
    var capturedProducts = [Plan: String]()

    func setPlans(_ plans: [String: Plan]) {
        for (identifier, plan) in plans {
            capturedProducts[plan] = identifier
        }
        setPlanCalledAttempt += 1
    }

    func setDefaultPlanProducts() {
        setPlans([
            AppConstants.InApp.monthlyProductIdentifier: .monthly,
            AppConstants.InApp.yearlyProductIdentifier: .yearly
        ])
    }
}
