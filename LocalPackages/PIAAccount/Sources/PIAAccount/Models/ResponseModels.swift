import Foundation

// MARK: - Account Information

/// Account status and subscription details.
///
/// Contains comprehensive information about a PIA account including subscription status,
/// expiration details, and account capabilities.
public struct AccountInformation: Codable, Sendable {
    /// Whether the account is currently active and can use VPN services
    public let active: Bool

    /// Whether the account can send referral invites
    public let canInvite: Bool

    /// Whether the subscription has been canceled (but may still be active until expiration)
    public let canceled: Bool

    /// Number of days remaining until subscription expires
    public let daysRemaining: Int

    /// Email address associated with the account
    public let email: String

    /// Unix timestamp when the subscription expires
    public let expirationTime: Int

    /// Whether to show expiration alert to the user
    public let expireAlert: Bool

    /// Whether the subscription has already expired
    public let expired: Bool

    /// Whether payment is required to reactivate the account
    public let needsPayment: Bool

    /// Subscription plan name (e.g., "yearly", "monthly")
    public let plan: String

    /// App Store product identifier (iOS only), if applicable
    public let productId: String?

    /// Whether the subscription automatically renews
    public let recurring: Bool

    /// URL to renew the subscription
    public let renewUrl: String

    /// Whether the subscription can be renewed
    public let renewable: Bool

    /// PIA account username
    public let username: String
}

// MARK: - iOS Subscription Information

/// iOS subscription information including available products
public struct IOSSubscriptionInformation: Codable, Sendable {
    public let availableProducts: [AvailableProduct]
    public let eligibleForTrial: Bool
    public let receipt: Receipt
    public let status: String

    public struct AvailableProduct: Codable, Sendable {
        public let id: String
        public let legacy: Bool
        public let plan: String
        public let price: String
    }

    public struct Receipt: Codable, Sendable {
        public let eligibleForTrial: Bool
    }
}

// MARK: - Dedicated IP Information

/// Response containing dedicated IP information
public struct DedicatedIPInformationResponse: Codable, Sendable {
    public let result: [DedicatedIPInformation]
}

/// Dedicated IP status and details
public struct DedicatedIPInformation: Codable, Sendable {
    public let id: String?
    public let ip: String?
    public let cn: String?
    public let groups: [String]?
    public let dipExpire: Int?
    public let dipToken: String
    public let status: Status

    public enum Status: String, Codable, Sendable {
        case active
        case expired
        case invalid
        case error
    }

    enum CodingKeys: String, CodingKey {
        case id, ip, cn, groups
        case dipExpire = "dip_expire"
        case dipToken = "dip_token"
        case status
    }
}

// MARK: - Client Status Information

/// Client connection status and IP information
public struct ClientStatusInformation: Codable, Sendable {
    public let connected: Bool
    public let ip: String?
}

// MARK: - Feature Flags Information

/// Feature flags for the application
public struct FeatureFlagsInformation: Codable, Sendable {
    public let flags: [String: Bool]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.flags = try container.decode([String: Bool].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(flags)
    }
}

// MARK: - Message Information

/// In-app message information
public struct MessageInformation: Codable, Sendable {
    public let message: Message?

    public struct Message: Codable, Sendable {
        public let id: String
        public let text: [String: String]
        public let link: [String: String]
        public let view: String
        public let action: String?
    }
}

// MARK: - Invites Details Information

/// Referral/invite program details
public struct InvitesDetailsInformation: Codable, Sendable {
    public let invites: Invites

    public struct Invites: Codable, Sendable {
        public let total: Int
        public let rewarded: Int
    }
}

// MARK: - Redeem Information

/// Gift card/promo code redemption result
public struct RedeemInformation: Codable, Sendable {
    public let username: String?
    public let message: String?
}

// MARK: - Sign Up Information

/// New account credentials after sign up
public struct SignUpInformation: Codable, Sendable {
    public let username: String
    public let password: String
}
