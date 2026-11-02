//
//  HasActiveSubscriptionUseCase.swift
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

import PIALibrary

/// Whether this App Store account already holds a live subscription, so the paywall can offer
/// welcome-back instead of selling a second account. Does not call `AppStore.sync()`.
public struct HasActiveSubscriptionUseCase {
    private let currentReceipt: GetCurrentSubscriptionReceiptUseCase

    public init(store: InAppProvider) {
        self.currentReceipt = GetCurrentSubscriptionReceiptUseCase(store: store)
    }

    public func callAsFunction() async -> Bool {
        await currentReceipt() != nil
    }
}
