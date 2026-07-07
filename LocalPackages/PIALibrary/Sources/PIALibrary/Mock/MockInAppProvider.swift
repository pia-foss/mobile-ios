//
//  MockInAppProvider.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2020 Private Internet Access, Inc.
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
import StoreKit

#if os(iOS) || os(tvOS)
    struct MockProduct: InAppProduct {
        enum Native { case none }

        let identifier: String

        let price: Decimal

        let priceLocale = Locale.current

        let native: Native = .none

        var hasIntroOffer: Bool { false }

        init(_ identifier: String, _ price: Decimal) {
            self.identifier = identifier
            self.price = price
        }
    }

    private struct MockTransaction: InAppTransaction {
        enum Native { case none }

        let identifier: String = "1234567890"

        let jwsRepresentation: JWS = JWS("mock-jws-transaction")!

        let native: Native = .none
    }

    final class MockInAppProvider: InAppProvider, ConfigurationAccess {

        init(jws: JWS? = JWS("mock-jws-transaction")!) {
            self.entitlementJWS = jws
        }
        var availableProducts: [any InAppProduct]?

        var entitlementJWS: JWS?

        func startObservingTransactions() {
        }

        func stopObservingTransactions() {
        }

        func fetchProducts(identifiers: Set<String>) async -> Result<[any InAppProduct], StoreKitError> {
            availableProducts = []
            for (i, identifier) in accessedConfiguration.allProductIdentifiers().enumerated() {
                let price = (Decimal(i + 1) * 50.0)
                availableProducts?.append(MockProduct(identifier, price))
            }
            return .success(availableProducts ?? [])
        }

        func purchase(product: any InAppProduct) async -> Result<any InAppTransaction, ClientError> {
            return .success(MockTransaction())
        }

        func finishTransaction(_ transaction: any InAppTransaction, success: Bool) {
        }

        func currentEntitlementJWS() async -> JWS? {
            return entitlementJWS
        }

        func synchronizeEntitlements() async -> Error? {
            return nil
        }
    }
#endif
