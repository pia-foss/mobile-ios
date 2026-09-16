import Foundation
import PIABase

// MARK: - Promotional Offers Eligibility

/// Request body for `POST /api/client/v5/promo_offers/eligibility`.
///
/// The endpoint is unauthenticated: the signed StoreKit 2 transaction (`receipt`) is itself the
/// proof of subscription. See the *Apple Promotional Offers* Confluence doc (space PAC).
public struct PromoOffersEligibilityRequest: Encodable, Sendable {
    private let store: String = "apple_app_store"
    public let receipt: JWS
    /// ISO 3166-1 alpha-2 device country. Optional; used by server eligibility rules.
    public let country: String?

    public init(receipt: JWS, country: String?) {
        self.receipt = receipt
        self.country = country
    }
}

/// Response for `POST /api/client/v5/promo_offers/eligibility`.
///
/// A non-empty `offerIdentifiers` means the subscriber may redeem those offers; an empty array
/// means "not eligible" (`reason` may accompany either case).
public struct PromoOffersEligibilityResponse: Decodable, Sendable {
    /// Promotional offer IDs exactly as configured in App Store Connect.
    public let offerIdentifiers: [String]
    public let reason: String?

    enum CodingKeys: String, CodingKey {
        case offerIdentifiers = "offer_identifiers"
        case reason
    }
}

// MARK: - Promotional Offers Signing

/// Request body for `POST /api/client/v5/promo_offers/sign`.
public struct PromoOffersSignRequest: Encodable, Sendable {
    private let store: String = "apple_app_store"
    public let receipt: JWS
    public let productIdentifier: String
    public let offerIdentifier: String
    /// UUID that must exactly match the value set on the purchase
    /// (`Product.PurchaseOption.appAccountToken`). Sent lowercased, per Apple's spec.
    public let appAccountToken: String
    /// ISO 3166-1 alpha-2 device country. Optional.
    public let country: String?

    public init(
        receipt: JWS,
        productIdentifier: String,
        offerIdentifier: String,
        appAccountToken: UUID,
        country: String?
    ) {
        self.receipt = receipt
        self.productIdentifier = productIdentifier
        self.offerIdentifier = offerIdentifier
        self.appAccountToken = appAccountToken.uuidString.lowercased()
        self.country = country
    }

    enum CodingKeys: String, CodingKey {
        case store
        case receipt
        case productIdentifier = "product_identifier"
        case offerIdentifier = "offer_identifier"
        case appAccountToken = "app_account_token"
        case country
    }
}

/// Response for `POST /api/client/v5/promo_offers/sign`.
///
/// The values map directly onto `Product.PurchaseOption.promotionalOffer(...)`.
public struct PromoOffersSignResponse: Decodable, Sendable {
    public let status: String
    /// Base64-encoded ECDSA signature.
    public let signature: String
    /// Lowercase UUID, single-use.
    public let nonce: String
    /// Milliseconds since epoch (signature is time-sensitive).
    public let timestamp: Int
    /// App Store Connect subscription key ID used to sign.
    public let keyIdentifier: String

    enum CodingKeys: String, CodingKey {
        case status
        case signature
        case nonce
        case timestamp
        case keyIdentifier = "key_identifier"
    }
}
