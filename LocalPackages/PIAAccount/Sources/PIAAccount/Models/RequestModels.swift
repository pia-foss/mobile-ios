import Foundation
import PIABase

// MARK: - iOS Sign Up Information

/// Information required for iOS account sign up with App Store receipt
public struct IOSSignupInformation: Encodable, Sendable {
    private let store: String = "apple_app_store"
    public let receipt: JWS
    private let receipt_version: Int = 2
    public let email: String
    public let marketing: String?
    public let debug: String?

    public init(
        receipt: JWS,
        email: String,
        marketing: String? = nil,
        debug: String? = nil
    ) {
        self.receipt = receipt
        self.email = email
        self.marketing = marketing
        self.debug = debug
    }
}

// MARK: - Restore purchase information

public struct LoginRestorePurchasePayload: Encodable {
    private let store: String = "apple_app_store"
    private let receipt: JWS
    private let receipt_version: Int = 2

    public init(receipt: JWS) {
        self.receipt = receipt
    }
}

// MARK: - iOS Payment Information

/// Information required for iOS payment updates
public struct IOSPaymentInformation: Encodable, Sendable {
    private let store: String = "apple_app_store"
    public let receipt: JWS
    private let receipt_version: Int = 2
    public let marketing: String
    public let debug: String

    public init(
        receipt: JWS,
        marketing: String,
        debug: String
    ) {
        self.receipt = receipt
        self.marketing = marketing
        self.debug = debug
    }
}

// MARK: - Dedicated IP Token Request

/// Request body for acquiring a Dedicated IP token
struct GetDedicatedIPTokenRequest: Codable, Sendable {
    let countryCode: String
    let region: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case region
    }
}
