import Foundation

/// Actor-based token manager with automatic refresh logic
actor TokenManager {
    private let keychain: KeychainStorage
    private let tokenRefreshThreshold: TimeInterval

    private static let apiTokenKey = "API_TOKEN_KEY"
    private static let vpnTokenKey = "VPN_TOKEN_KEY"

    /// Creates a new TokenManager
    /// - Parameters:
    ///   - keychainService: Service identifier for Keychain storage
    ///   - refreshThreshold: Number of days before expiration to trigger refresh (default: 21 days)
    init(
        keychainService: String = "com.pia.account.tokens",
        refreshThreshold: TimeInterval = 21 * 24 * 60 * 60
    ) {
        self.keychain = KeychainStorage(service: keychainService)
        self.tokenRefreshThreshold = refreshThreshold
    }

    // MARK: - API Token Management

    /// Stores an API token response in the Keychain
    /// - Parameter response: The API token response to store
    /// - Throws: PIAAccountError if storage fails
    func storeAPIToken(_ response: APITokenResponse) throws {
        try keychain.set(response, forKey: Self.apiTokenKey)
    }

    /// Retrieves the stored API token response
    /// - Returns: The API token response, or nil if not stored
    /// - Throws: PIAAccountError if retrieval fails
    func getAPIToken() throws -> APITokenResponse? {
        return try keychain.get(APITokenResponse.self, forKey: Self.apiTokenKey)
    }

    /// Gets the raw API token string (synchronous access)
    /// - Returns: The API token string, or nil if not stored
    func getAPITokenString() throws -> String? {
        return try getAPIToken()?.apiToken
    }

    /// Checks if the API token needs refresh (< 21 days until expiration)
    /// - Returns: true if refresh is needed, false otherwise
    /// - Throws: PIAAccountError if token retrieval or date parsing fails
    func needsAPITokenRefresh() throws -> Bool {
        guard let tokenResponse = try getAPIToken() else {
            return false  // No token to refresh
        }

        do {
            let daysUntilExpiration = try tokenResponse.daysUntilExpiration()
            let thresholdDays = tokenRefreshThreshold / (24 * 60 * 60)
            return daysUntilExpiration < thresholdDays
        } catch {
            // If we can't parse the date, consider it needing refresh
            return true
        }
    }

    // MARK: - VPN Token Management

    /// Stores a VPN token response in the Keychain
    /// - Parameter response: The VPN token response to store
    /// - Throws: PIAAccountError if storage fails
    func storeVPNToken(_ response: VPNTokenResponse) throws {
        try keychain.set(response, forKey: Self.vpnTokenKey)
    }

    /// Retrieves the stored VPN token response
    /// - Returns: The VPN token response, or nil if not stored
    /// - Throws: PIAAccountError if retrieval fails
    func getVPNTokenResponse() throws -> VPNTokenResponse? {
        return try keychain.get(VPNTokenResponse.self, forKey: Self.vpnTokenKey)
    }

    /// Gets the formatted VPN token string ("vpn_token_{username}:{password}")
    /// - Returns: The formatted VPN token, or nil if not stored
    /// - Throws: PIAAccountError if retrieval fails
    func getVPNToken() throws -> String? {
        return try getVPNTokenResponse()?.formattedToken
    }

    /// Checks if the VPN token needs refresh (< 21 days until expiration or missing)
    /// - Returns: true if refresh is needed, false otherwise
    /// - Throws: PIAAccountError if token retrieval or date parsing fails
    func needsVPNTokenRefresh() throws -> Bool {
        guard let tokenResponse = try getVPNTokenResponse() else {
            return true  // No token = needs refresh
        }

        do {
            let daysUntilExpiration = try tokenResponse.daysUntilExpiration()
            let thresholdDays = tokenRefreshThreshold / (24 * 60 * 60)
            return daysUntilExpiration < thresholdDays
        } catch {
            // If we can't parse the date, consider it needing refresh
            return true
        }
    }

    // MARK: - Token Lifecycle

    /// Checks if both tokens need refresh
    /// - Returns: Tuple of (apiTokenNeedsRefresh, vpnTokenNeedsRefresh)
    /// - Throws: PIAAccountError if token retrieval or date parsing fails
    func needsTokenRefresh() throws -> (api: Bool, vpn: Bool) {
        let apiNeedsRefresh = try needsAPITokenRefresh()
        let vpnNeedsRefresh = try needsVPNTokenRefresh()
        return (apiNeedsRefresh, vpnNeedsRefresh)
    }

    /// Clears all stored tokens from the Keychain
    /// - Throws: PIAAccountError if deletion fails
    func clearAllTokens() throws {
        try keychain.delete(forKey: Self.apiTokenKey)
        try keychain.delete(forKey: Self.vpnTokenKey)
    }

    /// Checks if any tokens are stored
    /// - Returns: true if either API or VPN token exists
    /// - Throws: PIAAccountError if check fails
    func hasTokens() throws -> Bool {
        let hasAPI = try keychain.exists(forKey: Self.apiTokenKey)
        let hasVPN = try keychain.exists(forKey: Self.vpnTokenKey)
        return hasAPI || hasVPN
    }
}

// MARK: - Token Refresh Coordinator

extension TokenManager {
    /// Coordinates token refresh to prevent duplicate requests
    private static var apiTokenRefreshTask: Task<Void, Error>?
    private static var vpnTokenRefreshTask: Task<Void, Error>?

    /// Executes API token refresh with deduplication
    /// - Parameter block: The async block that performs the refresh
    /// - Throws: PIAAccountError if refresh fails
    nonisolated func refreshAPITokenIfNeeded(_ block: @escaping () async throws -> Void) async throws {
        // Check if there's already a refresh in progress
        if let existingTask = Self.apiTokenRefreshTask {
            // Wait for the existing refresh to complete
            return try await existingTask.value
        }

        // Create a new refresh task
        let task = Task {
            defer { Self.apiTokenRefreshTask = nil }
            try await block()
        }

        Self.apiTokenRefreshTask = task
        try await task.value
    }

    /// Executes VPN token refresh with deduplication
    /// - Parameter block: The async block that performs the refresh
    /// - Throws: PIAAccountError if refresh fails
    nonisolated func refreshVPNTokenIfNeeded(_ block: @escaping () async throws -> Void) async throws {
        // Check if there's already a refresh in progress
        if let existingTask = Self.vpnTokenRefreshTask {
            // Wait for the existing refresh to complete
            return try await existingTask.value
        }

        // Create a new refresh task
        let task = Task {
            defer { Self.vpnTokenRefreshTask = nil }
            try await block()
        }

        Self.vpnTokenRefreshTask = task
        try await task.value
    }
}
