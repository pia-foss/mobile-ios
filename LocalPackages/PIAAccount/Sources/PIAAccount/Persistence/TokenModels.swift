import Foundation

/// Internal model for API token response
struct APITokenResponse: Codable, Sendable {
    /// The API token string
    let apiToken: String

    /// ISO 8601 expiration date string
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case apiToken = "api_token"
        case expiresAt = "expires_at"
    }
}

/// Internal model for VPN token response
struct VPNTokenResponse: Codable, Sendable {
    /// VPN username token (vpn_secret1)
    let vpnUsernameToken: String

    /// VPN password token (vpn_secret2)
    let vpnPasswordToken: String

    /// ISO 8601 expiration date string
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case vpnUsernameToken = "vpn_secret1"
        case vpnPasswordToken = "vpn_secret2"
        case expiresAt = "expires_at"
    }

    /// Formats the VPN token as "vpn_token_{username}:{password}"
    var formattedToken: String {
        return "vpn_token_\(vpnUsernameToken):\(vpnPasswordToken)"
    }
}

// MARK: - Date Parsing Helpers

extension APITokenResponse {
    /// Parses the expiration date from ISO 8601 string
    func expirationDate() throws -> Date {
        guard let date = ISO8601DateFormatter().date(from: expiresAt) else {
            throw PIAAccountError.decodingFailed(
                NSError(domain: "PIAAccount", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid date format: \(expiresAt)"
                ])
            )
        }
        return date
    }

    /// Calculates days until expiration
    func daysUntilExpiration() throws -> Double {
        let expiration = try expirationDate()
        return expiration.timeIntervalSinceNow / (24 * 60 * 60)
    }
}

extension VPNTokenResponse {
    /// Parses the expiration date from ISO 8601 string
    func expirationDate() throws -> Date {
        guard let date = ISO8601DateFormatter().date(from: expiresAt) else {
            throw PIAAccountError.decodingFailed(
                NSError(domain: "PIAAccount", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid date format: \(expiresAt)"
                ])
            )
        }
        return date
    }

    /// Calculates days until expiration
    func daysUntilExpiration() throws -> Double {
        let expiration = try expirationDate()
        return expiration.timeIntervalSinceNow / (24 * 60 * 60)
    }
}
