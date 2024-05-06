//
//  PurchaseProductsProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class PurchaseProductsProviderMock: PurchaseProductsProviderType {
    private let result: Result<InAppTransaction, Error>
    
    init(result: Result<InAppTransaction, Error>) {
        self.result = result
    }
    
    func purchase(subscriptionOption: SubscriptionOption, _ callback: @escaping (Result<InAppTransaction, Error>) -> Void) {
        callback(result)
    }
}
