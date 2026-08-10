//
//  PaywallDependencies.swift
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

import Foundation
import PIALibrary

/// Everything the paywall needs from the outside world, as closures.
///
/// This is the `Client.providers` seam from ADR 0007: the reducer never reaches for a singleton, and
/// tests run the whole state machine with no `Client` stack, no StoreKit and no network.
/// `PaywallDependencies+Live` is the only file in this package that names `Client`.
/// Every closure is `@MainActor`: `InAppTransaction` and `AccountProvider` are not `Sendable`, so
/// keeping the whole seam on one actor is what lets those values be passed around at all.
public struct PaywallDependencies {
    /// Fetches the purchasable plans together with the App Store's current intro-offer eligibility.
    public var loadOffers: @MainActor () async -> Result<OffersPayload, PaywallError>

    /// `true` when this App Store account already owns a subscription.
    public var hasExistingEntitlement: @MainActor () async -> Bool

    public var purchase: @MainActor (PurchaseRequest) async -> Result<any InAppTransaction, PaywallError>

    /// Tells the App Store a transaction has been dealt with, so it stops being redelivered.
    public var finishTransaction: @MainActor (any InAppTransaction) async -> Void

    /// Restores a previous purchase and signs in with it.
    public var restore: @MainActor () async -> Result<UserAccount, PaywallError>

    public init(
        loadOffers: @escaping @MainActor () async -> Result<OffersPayload, PaywallError>,
        hasExistingEntitlement: @escaping @MainActor () async -> Bool,
        purchase: @escaping @MainActor (PurchaseRequest) async -> Result<any InAppTransaction, PaywallError>,
        finishTransaction: @escaping @MainActor (any InAppTransaction) async -> Void,
        restore: @escaping @MainActor () async -> Result<UserAccount, PaywallError>
    ) {
        self.loadOffers = loadOffers
        self.hasExistingEntitlement = hasExistingEntitlement
        self.purchase = purchase
        self.finishTransaction = finishTransaction
        self.restore = restore
    }
}
