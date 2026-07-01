//
//  InAppProviderSpy.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import StoreKit

class InAppProviderSpy: InAppProvider {
    var startObservingTransactionsCalledAttempt = 0
    var availableProducts: [any InAppProduct]?
    var entitlementJWS: JWS?

    func startObservingTransactions() {
        startObservingTransactionsCalledAttempt += 1
    }

    func stopObservingTransactions() {}

    func fetchProducts(identifiers: Set<String>) async -> Result<[any InAppProduct], StoreKitError> {
        return .success([])
    }

    func purchase(product: any InAppProduct) async -> Result<any InAppTransaction, ClientError> {
        return .failure(.productUnavailable)
    }

    func finishTransaction(_ transaction: any InAppTransaction, success: Bool) {}

    func currentEntitlementJWS() async -> JWS? {
        return entitlementJWS
    }

    func synchronizeEntitlements() async -> Error? {
        return nil
    }
}
