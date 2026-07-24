//
//  PaymentProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 20/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIABase

final class PaymentProvider: PaymentProviderType {
    private let store: InAppProvider

    init(store: InAppProvider) {
        self.store = store
    }

    func refreshPaymentReceipt(_ completion: @escaping (Result<JWS, Error>) -> Void) {
        Task { [weak self] in
            if let error = await self?.store.synchronizeEntitlements() {
                completion(.failure(error))
                return
            }

            guard let jws = await self?.store.currentEntitlementJWS() else {
                completion(.failure(ClientError.unexpectedReply))
                return
            }

            completion(.success(jws))
        }
    }
}
