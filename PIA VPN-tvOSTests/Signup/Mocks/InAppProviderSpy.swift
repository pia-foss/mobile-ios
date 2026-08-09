//
//  InAppProviderSpy.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIABase
import PIALibrary
import StoreKit

class InAppProviderSpy: InAppProvider {
    var startObservingTransactionsCalledAttempt = 0
    var availableProducts: [any InAppProduct]?
    var entitlementJWS: JWS?
    var isEligibleForIntroOfferResult = false
    private(set) var isEligibleForIntroOfferCalledAttempt = 0

    func startObservingTransactions() {
        startObservingTransactionsCalledAttempt += 1
    }

    func stopObservingTransactions() {}

    func fetchProducts(identifiers: Set<String>) async -> Result<[any InAppProduct], StoreKitError> {
        return .success([])
    }

    func isEligibleForIntroOffer(for product: any InAppProduct) async -> Bool {
        isEligibleForIntroOfferCalledAttempt += 1
        return isEligibleForIntroOfferResult
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
