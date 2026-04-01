//
//  PaymentProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 21/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class PaymentProviderMock: PaymentProviderType {
    private let result: Result<Data, any Error>
    
    init(result: Result<Data, any Error>) {
        self.result = result
    }
    
    func refreshPaymentReceipt(_ completion: @escaping (Result<Data, Error>) -> Void) {
        completion(result)
    }
}
