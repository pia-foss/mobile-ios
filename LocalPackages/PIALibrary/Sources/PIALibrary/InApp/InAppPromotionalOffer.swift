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

    public init(id: String, displayPrice: String) {
        self.id = id
        self.displayPrice = displayPrice
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
