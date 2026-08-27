//
//  InAppPromotionalOffer.swift
//  PIALibrary
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

public enum SubscriptionPeriodUnit: Int, Sendable, Equatable {
    case day = 0
    case week = 1
    case month = 2
    case year = 3
}

/// A promotional (win-back) offer configured on a subscription in App Store Connect.
///
/// A store-agnostic projection of `Product.SubscriptionOffer` so callers do not need to import
/// StoreKit. `id` matches the identifiers returned by the backend eligibility endpoint and is what
/// gets sent to the signing endpoint.
public struct InAppPromotionalOffer: Sendable, Equatable, Identifiable {
    /// The offer identifier, exactly as configured in App Store Connect.
    public let id: String
    /// Localized price of the offer (e.g. "$2.99").
    public let displayPrice: String
    public let periodValue: Int
    public let periodUnit: SubscriptionPeriodUnit
    public let periodCount: Int
    public let price: Decimal

    public var isFree: Bool { price == 0 }

    public var totalDays: Int {
        let daysPerUnit: Int
        switch periodUnit {
        case .day: daysPerUnit = 1
        case .week: daysPerUnit = 7
        case .month: daysPerUnit = 30
        case .year: daysPerUnit = 365
        }
        return periodValue * periodCount * daysPerUnit
    }

    public init(
        id: String,
        displayPrice: String,
        periodValue: Int = 0,
        periodUnit: SubscriptionPeriodUnit = .day,
        periodCount: Int = 0,
        price: Decimal = 0
    ) {
        self.id = id
        self.displayPrice = displayPrice
        self.periodValue = periodValue
        self.periodUnit = periodUnit
        self.periodCount = periodCount
        self.price = price
    }
}

/// The one-time signature payload returned by the backend, ready to attach to a purchase.
///
/// Fields map directly onto `Product.PurchaseOption.promotionalOffer(...)`. The backend returns the
/// signature base64-encoded, the nonce as a UUID string and the timestamp in milliseconds; callers
/// decode those into the shapes below before constructing this value.
public struct InAppPromotionalOfferSignature: Sendable, Equatable {
    public let offerID: String
    /// App Store Connect subscription key ID used to sign.
    public let keyID: String
    /// Single-use nonce.
    public let nonce: UUID
    /// Decoded (base64) ECDSA signature.
    public let signature: Data
    /// Milliseconds since epoch.
    public let timestamp: Int

    public init(offerID: String, keyID: String, nonce: UUID, signature: Data, timestamp: Int) {
        self.offerID = offerID
        self.keyID = keyID
        self.nonce = nonce
        self.signature = signature
        self.timestamp = timestamp
    }
}
