//
//  GetCurrentSubscriptionReceiptUseCase.swift
//  PIAPaywall
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

import PIABase
import PIALibrary

/// The signed receipt for this App Store account's current subscription, if any.
///
/// Reads what StoreKit already knows; does not call `AppStore.sync()`.
public struct GetCurrentSubscriptionReceiptUseCase {
    private let store: InAppProvider

    public init(store: InAppProvider) {
        self.store = store
    }

    public func callAsFunction() async -> JWS? {
        await store.currentEntitlementJWS()
    }
}
