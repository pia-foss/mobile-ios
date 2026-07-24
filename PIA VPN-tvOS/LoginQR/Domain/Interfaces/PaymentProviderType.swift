//
//  PaymentProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 21/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIABase

protocol PaymentProviderType {
    func refreshPaymentReceipt(_ completion: @escaping (Result<JWS, Error>) -> Void)
}
