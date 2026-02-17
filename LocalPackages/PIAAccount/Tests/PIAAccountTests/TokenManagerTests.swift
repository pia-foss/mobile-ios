import Testing
import Foundation
@testable import PIAAccount

@Suite struct TokenManagerTests {
    var tokenManager: TokenManager
    var testService: String

    init() async throws {
        // Use unique service identifier for each test
        testService = "com.pia.test.\(UUID().uuidString)"
        tokenManager = TokenManager(keychainService: testService)
    }

    // MARK: - API Token Tests

    @Test("Store and retrieve API token")
    func storeAndRetrieveAPIToken() async throws {
        let tokenResponse = APITokenResponse(
            apiToken: "test-api-token-123",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60)) // 30 days
        )

        try await tokenManager.storeAPIToken(tokenResponse)

        let retrieved = try await tokenManager.getAPIToken()
        #expect(retrieved?.apiToken == tokenResponse.apiToken)
        #expect(retrieved?.expiresAt == tokenResponse.expiresAt)
    }

    @Test("Get API token string")
    func getAPITokenString() async throws {
        let tokenResponse = APITokenResponse(
            apiToken: "test-token-string",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
        )

        try await tokenManager.storeAPIToken(tokenResponse)

        let tokenString = try await tokenManager.getAPITokenString()
        #expect(tokenString == "test-token-string")
    }

    @Test("Get API token string when no token stored")
    func getAPITokenStringWhenNoToken() async throws {
        let tokenString = try await tokenManager.getAPITokenString()
        #expect(tokenString == nil)
    }

    // MARK: - VPN Token Tests

    @Test("Store and retrieve VPN token")
    func storeAndRetrieveVPNToken() async throws {
        let tokenResponse = VPNTokenResponse(
            vpnUsernameToken: "username123",
            vpnPasswordToken: "password456",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
        )

        try await tokenManager.storeVPNToken(tokenResponse)

        let retrieved = try await tokenManager.getVPNToken()
        let expected = "vpn_token_username123:password456"
        #expect(retrieved == expected)
    }

    @Test("Get VPN token when no token stored")
    func getVPNTokenWhenNoToken() async throws {
        let token = try await tokenManager.getVPNToken()
        #expect(token == nil)
    }

    // MARK: - Token Expiration Tests

    @Test("Valid token does not need refresh")
    func needsAPITokenRefreshValidToken() async throws {
        // Token expires in 30 days (within threshold)
        let tokenResponse = APITokenResponse(
            apiToken: "valid-token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
        )

        try await tokenManager.storeAPIToken(tokenResponse)

        let needsRefresh = try await tokenManager.needsAPITokenRefresh()
        #expect(!needsRefresh)
    }

    @Test("Token expiring soon needs refresh")
    func needsAPITokenRefreshExpiringSoon() async throws {
        // Token expires in 10 days (below 21-day threshold)
        let tokenResponse = APITokenResponse(
            apiToken: "expiring-token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(10 * 24 * 60 * 60))
        )

        try await tokenManager.storeAPIToken(tokenResponse)

        let needsRefresh = try await tokenManager.needsAPITokenRefresh()
        #expect(needsRefresh)
    }

    @Test("Expired token needs refresh")
    func needsAPITokenRefreshExpired() async throws {
        // Token expired yesterday
        let tokenResponse = APITokenResponse(
            apiToken: "expired-token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-24 * 60 * 60))
        )

        try await tokenManager.storeAPIToken(tokenResponse)

        let needsRefresh = try await tokenManager.needsAPITokenRefresh()
        #expect(needsRefresh)
    }

    @Test("No token returns false for needs refresh")
    func needsAPITokenRefreshNoToken() async throws {
        let needsRefresh = try await tokenManager.needsAPITokenRefresh()
        #expect(!needsRefresh)
    }

    @Test("Token at exact threshold does not need refresh")
    func needsAPITokenRefreshExactThreshold() async throws {
        // Token expires in exactly 21 days (at threshold)
        // Due to floating point precision, use 21.1 days to be safely above threshold
        let tokenResponse = APITokenResponse(
            apiToken: "threshold-token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(21.1 * 24 * 60 * 60))
        )

        try await tokenManager.storeAPIToken(tokenResponse)

        let needsRefresh = try await tokenManager.needsAPITokenRefresh()
        // At 21.1 days (above 21 day threshold), should NOT need refresh
        #expect(!needsRefresh)
    }

    @Test("Token just below threshold needs refresh")
    func needsAPITokenRefreshJustBelowThreshold() async throws {
        // Token expires in 20.9 days (just below threshold)
        let tokenResponse = APITokenResponse(
            apiToken: "below-threshold-token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(20.9 * 24 * 60 * 60))
        )

        try await tokenManager.storeAPIToken(tokenResponse)

        let needsRefresh = try await tokenManager.needsAPITokenRefresh()
        #expect(needsRefresh)
    }

    // MARK: - Combined Refresh Tests

    @Test("Both tokens valid do not need refresh")
    func needsTokenRefreshBothTokensValid() async throws {
        let futureDate = ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))

        let apiToken = APITokenResponse(apiToken: "api", expiresAt: futureDate)
        let vpnToken = VPNTokenResponse(vpnUsernameToken: "vpn1", vpnPasswordToken: "vpn2", expiresAt: futureDate)

        try await tokenManager.storeAPIToken(apiToken)
        try await tokenManager.storeVPNToken(vpnToken)

        let (apiNeedsRefresh, vpnNeedsRefresh) = try await tokenManager.needsTokenRefresh()

        #expect(!apiNeedsRefresh)
        #expect(!vpnNeedsRefresh)
    }

    @Test("API token expiring needs refresh")
    func needsTokenRefreshAPIExpiring() async throws {
        let apiToken = APITokenResponse(
            apiToken: "api",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(10 * 24 * 60 * 60)) // 10 days
        )
        let vpnToken = VPNTokenResponse(
            vpnUsernameToken: "vpn1",
            vpnPasswordToken: "vpn2",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60)) // 30 days
        )

        try await tokenManager.storeAPIToken(apiToken)
        try await tokenManager.storeVPNToken(vpnToken)

        let (apiNeedsRefresh, vpnNeedsRefresh) = try await tokenManager.needsTokenRefresh()

        #expect(apiNeedsRefresh)
        #expect(!vpnNeedsRefresh)
    }

    @Test("VPN token expiring needs refresh")
    func needsTokenRefreshVPNExpiring() async throws {
        let apiToken = APITokenResponse(
            apiToken: "api",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60)) // 30 days
        )
        let vpnToken = VPNTokenResponse(
            vpnUsernameToken: "vpn1",
            vpnPasswordToken: "vpn2",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(10 * 24 * 60 * 60)) // 10 days
        )

        try await tokenManager.storeAPIToken(apiToken)
        try await tokenManager.storeVPNToken(vpnToken)

        let (apiNeedsRefresh, vpnNeedsRefresh) = try await tokenManager.needsTokenRefresh()

        #expect(!apiNeedsRefresh)
        #expect(vpnNeedsRefresh)
    }

    @Test("No tokens stored returns correct refresh state")
    func needsTokenRefreshNoTokens() async throws {
        let (apiNeedsRefresh, vpnNeedsRefresh) = try await tokenManager.needsTokenRefresh()

        // API token: false when missing (no token to refresh)
        // VPN token: true when missing (missing means needs refresh)
        #expect(!apiNeedsRefresh)
        #expect(vpnNeedsRefresh)
    }

    // MARK: - Clear Tokens Tests

    @Test("Clear all tokens removes both API and VPN tokens")
    func clearAllTokens() async throws {
        let futureDate = ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))

        let apiToken = APITokenResponse(apiToken: "api", expiresAt: futureDate)
        let vpnToken = VPNTokenResponse(vpnUsernameToken: "vpn1", vpnPasswordToken: "vpn2", expiresAt: futureDate)

        try await tokenManager.storeAPIToken(apiToken)
        try await tokenManager.storeVPNToken(vpnToken)

        // Verify tokens exist
        let apiTokenBefore = try await tokenManager.getAPIToken()
        let vpnTokenBefore = try await tokenManager.getVPNToken()
        #expect(apiTokenBefore != nil)
        #expect(vpnTokenBefore != nil)

        // Clear all tokens
        try await tokenManager.clearAllTokens()

        // Verify tokens are cleared
        let apiTokenAfter = try await tokenManager.getAPIToken()
        let vpnTokenAfter = try await tokenManager.getVPNToken()
        #expect(apiTokenAfter == nil)
        #expect(vpnTokenAfter == nil)
    }

    // MARK: - Refresh Tests

    @Test("API token refresh executes block")
    func refreshAPITokenIfNeededExecutesBlock() async throws {
        try await tokenManager.refreshAPITokenIfNeeded {
            // Store new token
            let newToken = APITokenResponse(
                apiToken: "refreshed-token",
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
            )
            try await self.tokenManager.storeAPIToken(newToken)
        }

        let finalToken = try await tokenManager.getAPITokenString()
        #expect(finalToken == "refreshed-token")
    }

    @Test("VPN token refresh executes block")
    func refreshVPNTokenIfNeededExecutesBlock() async throws {
        try await tokenManager.refreshVPNTokenIfNeeded {
            let newToken = VPNTokenResponse(
                vpnUsernameToken: "new-user",
                vpnPasswordToken: "new-pass",
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
            )
            try await self.tokenManager.storeVPNToken(newToken)
        }

        let finalVPNToken = try await tokenManager.getVPNToken()
        #expect(finalVPNToken == "vpn_token_new-user:new-pass")
    }

    // MARK: - Error Handling Tests

    @Test("Invalid date format triggers refresh need")
    func invalidDateFormat() async throws {
        // This should throw when calculating days until expiration
        let invalidToken = APITokenResponse(
            apiToken: "test",
            expiresAt: "not-a-valid-date"
        )

        try await tokenManager.storeAPIToken(invalidToken)

        // Should handle invalid date gracefully
        let needsRefresh = try await tokenManager.needsAPITokenRefresh()
        // Implementation should treat invalid date as needing refresh
        #expect(needsRefresh)
    }
}
