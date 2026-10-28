//
//  HasActiveSubscriptionUseCaseTests.swift
//  PIAPaywallTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import PIABase
import PIALibrary
import StoreKit
import Testing

@testable import PIAPaywall

struct HasActiveSubscriptionUseCaseTests {

    @Test
    func isSubscribed_whenTheStoreHoldsAReceipt() async {
        let sut = HasActiveSubscriptionUseCase(store: InAppProviderStub(receipt: JWS("stub-jws")!))

        #expect(await sut())
    }

    @Test
    func isNotSubscribed_whenTheStoreHoldsNoReceipt() async {
        let sut = HasActiveSubscriptionUseCase(store: InAppProviderStub(receipt: nil))

        #expect(await sut() == false)
    }
}

/// Answers only `currentSubscriptionReceipt()`; nothing else is reached by the use case.
private final class InAppProviderStub: InAppProvider {
    private let receipt: JWS?

    init(receipt: JWS?) {
        self.receipt = receipt
    }

    var availableProducts: [any InAppProduct]? { nil }

    func startObservingTransactions() {}

    func stopObservingTransactions() {}

    func fetchProducts(identifiers: Set<String>) async -> Result<[any InAppProduct], StoreKitError> {
        .success([])
    }

    func purchase(product: any InAppProduct) async -> Result<any InAppTransaction, ClientError> {
        .failure(.unexpectedReply)
    }

    func purchase(
        product: any InAppProduct,
        promotionalOffer signature: InAppPromotionalOfferSignature,
        appAccountToken: UUID
    ) async -> Result<any InAppTransaction, ClientError> {
        .failure(.unexpectedReply)
    }

    func eligibleDaysForIntroOffer(for product: any InAppProduct) async -> Int { 0 }

    func finishTransaction(_ transaction: any InAppTransaction, success: Bool) {}

    func currentSubscriptionReceipt() async -> SubscriptionReceipt? {
        receipt.map { SubscriptionReceipt(jws: $0, expiration: nil) }
    }

    func promotionalOffers(for product: any InAppProduct) async -> [InAppPromotionalOffer] { [] }

    func synchronizeEntitlements() async -> Error? { nil }
}
