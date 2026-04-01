//
//  PurchaseProductUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS
import PIALibrary

class PurchaseProductUseCaseMock: PurchaseProductUseCaseType {
    private let result: Result<InAppTransaction, Error>
    
    init(result: Result<InAppTransaction, Error>) {
        self.result = result
    }
    
    func callAsFunction(subscriptionOption: SubscriptionOption) async throws -> InAppTransaction {
        switch result {
            case .success(let transaction):
                return transaction
            case .failure(let error):
                throw error
        }
    }
}
