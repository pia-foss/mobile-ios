//
//  PaymentProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 21/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIABase

@testable import PIA_VPN_tvOS

final class PaymentProviderMock: PaymentProviderType {
    private let result: Result<JWS, any Error>
    private let currentReceipt: JWS?

    init(result: Result<JWS, any Error>, currentReceipt: JWS? = nil) {
        self.result = result
        self.currentReceipt = currentReceipt
    }

    func refreshPaymentReceipt(_ completion: @escaping (Result<JWS, Error>) -> Void) {
        completion(result)
    }

    func currentPaymentReceipt() async -> JWS? {
        currentReceipt
    }
}
