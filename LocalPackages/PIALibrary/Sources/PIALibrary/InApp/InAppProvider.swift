//
//  InAppProvider.swift
//  PIALibrary
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

public protocol InAppProvider: AnyObject {
    var availableProducts: [any InAppProduct]? { get }

    func startObservingTransactions()

    func stopObservingTransactions()

    func fetchProducts(identifiers: Set<String>) async -> Result<[any InAppProduct], StoreKitError>

    func purchase(product: any InAppProduct) async -> Result<any InAppTransaction, ClientError>

    func finishTransaction(_ transaction: any InAppTransaction, success: Bool)

    /// The signed JWS representation of the newest active subscription entitlement, or `nil` if none.
    ///
    /// Used as the `receipt` for backend flows where no fresh purchase transaction is available
    /// (login-with-receipt, restore, subscription pricing).
    func currentEntitlementJWS() async -> JWS?

    /// Forces a synchronization with the App Store. Used by "restore purchases".
    ///
    /// - Returns: an `Error` if the sync failed, or `nil` on success.
    func synchronizeEntitlements() async -> Error?
}
