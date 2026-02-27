import Foundation

/// Main implementation of PIAAccountAPI
public actor PIAAccountClient: PIAAccountAPI {
    private let endpointManager: EndpointManager
    private let tokenManager: TokenManager
    private let userAgent: String

    /// Deprecated: Unsafe storage for backwards-compatible sync token access
    /// Remove this when migrating to async API
    nonisolated(unsafe) private static var _cachedApiToken: String?
    nonisolated(unsafe) private static var _cachedVpnToken: String?

    /// Creates a new account client
    internal init(
        endpointProvider: PIAAccountEndpointProvider,
        certificate: String?,
        userAgent: String
    ) {
        self.endpointManager = EndpointManager(
            endpointProvider: endpointProvider,
            certificate: certificate,
            userAgent: userAgent
        )
        self.tokenManager = TokenManager()
        self.userAgent = userAgent
    }

    // MARK: - Token Access

    public var apiToken: String? {
        get async {
            let token = try? await tokenManager.getAPITokenString()
            Self._cachedApiToken = token
            return token
        }
    }

    public var vpnToken: String? {
        get async {
            let token = try? await tokenManager.getVPNToken()
            Self._cachedVpnToken = token
            return token
        }
    }

    /// Deprecated: Use async apiToken property instead
    @available(*, deprecated, message: "Use async apiToken property instead")
    public nonisolated var syncApiToken: String? {
        Self._cachedApiToken
    }

    /// Deprecated: Use async vpnToken property instead
    @available(*, deprecated, message: "Use async vpnToken property instead")
    public nonisolated var syncVpnToken: String? {
        Self._cachedVpnToken
    }
    private func updateTokenCache() async {
        let apiToken = try? await tokenManager.getAPITokenString()
        let vpnToken = try? await tokenManager.getVPNToken()
        Self._cachedApiToken = apiToken
        Self._cachedVpnToken = vpnToken
    }

    /// Clears the token cache - called after logout
    private func clearTokenCache() {
        Self._cachedApiToken = nil
        Self._cachedVpnToken = nil
    }

    // MARK: - Authentication

    public func loginWithCredentials(username: String, password: String) async throws {
        let bodyData = try JSONEncoder.piaCodable.encode([
            "username": username,
            "password": password
        ])

        // Request API token
        let apiTokenResponse: APITokenResponse = try await endpointManager.executeWithFailover(
            path: .login,
            method: .post,
            bodyType: .json(bodyData)
        )

        // Store API token
        try await tokenManager.storeAPIToken(apiTokenResponse)

        // Request VPN token
        try await refreshVPNToken()
    }

    public func loginWithReceipt(receiptBase64: String) async throws {
        let bodyData = try JSONEncoder.piaCodable.encode([
            "store": "apple_app_store",
            "receipt": receiptBase64
        ])

        // Request API token
        let apiTokenResponse: APITokenResponse = try await endpointManager.executeWithFailover(
            path: .login,
            method: .post,
            bodyType: .json(bodyData)
        )

        // Store API token
        try await tokenManager.storeAPIToken(apiTokenResponse)

        // Request VPN token
        try await refreshVPNToken()
    }

    public func loginLink(email: String) async throws {
        let formParams = ["email": email]

        try await endpointManager.executeVoidWithFailover(
            path: .loginLink,
            method: .post,
            bodyType: .formEncoded(formParams)
        )
    }

    public func migrateApiToken(apiToken: String) async throws {
        // Use "Token" authorization header (matching Kotlin Account.kt line 1726)
        let headers = ["Authorization": "Token \(apiToken)"]

        let apiTokenResponse: APITokenResponse = try await endpointManager.executeWithFailover(
            path: .refreshAPIToken,
            method: .post,
            headers: headers
        )

        try await tokenManager.storeAPIToken(apiTokenResponse)
        try await refreshVPNToken()
    }

    public func logout() async throws {
        // Get API token for logout request
        guard let apiToken = try await tokenManager.getAPITokenString() else {
            // No token to logout - just clear local storage
            try await tokenManager.clearAllTokens()
            return
        }

        // Send logout request
        let headers = ["Authorization": "Bearer \(apiToken)"]

        try? await endpointManager.executeVoidWithFailover(
            path: .logout,
            method: .delete,
            headers: headers
        )

        // Clear tokens regardless of logout request result
        try await tokenManager.clearAllTokens()
    }

    public func validateLoginQR(qrToken: String) async throws -> String {
        // Validate QR token by sending it as Bearer token (matching Kotlin IOSAccount.kt line 161)
        let headers = [
            "Authorization": "Bearer \(qrToken)",
            "accept": "application/json"
        ]

        // Request validates the QR token and returns an API token
        let apiTokenResponse: APITokenResponse = try await endpointManager.executeWithFailover(
            path: .validateQR,
            method: .post,
            headers: headers
        )

        // Return the API token (do NOT persist tokens - matching Kotlin behavior lines 172-173)
        return apiTokenResponse.apiToken
    }

    // MARK: - Account Management

    public func accountDetails() async throws -> AccountInformation {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]

        return try await endpointManager.executeWithFailover(
            path: .accountDetails,
            method: .get,
            headers: headers
        )
    }

    public func deleteAccount() async throws {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]

        try await endpointManager.executeVoidWithFailover(
            path: .deleteAccount,
            method: .delete,
            headers: headers
        )

        // Clear tokens after account deletion
        try await tokenManager.clearAllTokens()
    }

    public func clientStatus(requestTimeoutMillis: Int = 30000) async throws -> ClientStatusInformation {
        return try await endpointManager.executeWithFailover(
            path: .clientStatus,
            method: .get
        )
    }

    // MARK: - Email Management

    public func setEmail(email: String, resetPassword: Bool) async throws -> String? {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]
        let formParams = [
            "email": email,
            "reset_password": resetPassword ? "true" : "false"
        ]

        let response: SetEmailInformation = try await endpointManager.executeWithFailover(
            path: .setEmail,
            method: .post,
            bodyType: .formEncoded(formParams),
            headers: headers
        )

        return response.password
    }

    public func setEmail(username: String, password: String, email: String, resetPassword: Bool) async throws -> String? {
        // Create Basic Auth header with username:password (matching Kotlin IOSAccount.kt line 244-247)
        let credentials = "\(username):\(password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            throw PIAAccountError.encodingFailed(
                NSError(domain: "PIAAccount", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode credentials"])
            )
        }
        let base64Credentials = credentialsData.base64EncodedString()
        let headers = ["Authorization": "Basic \(base64Credentials)"]

        let formParams = [
            "username": username,
            "password": password,
            "email": email,
            "reset_password": resetPassword ? "true" : "false"
        ]

        let response: SetEmailInformation = try await endpointManager.executeWithFailover(
            path: .setEmail,
            method: .post,
            bodyType: .formEncoded(formParams),
            headers: headers
        )

        return response.password
    }

    // MARK: - Dedicated IP

    public func supportedDedicatedIPCountries() async throws -> DipCountriesResponse {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Token \(apiToken)"]

        return try await endpointManager.executeWithFailover(
            path: .supportedDedicatedIPCountries,
            method: .get,
            headers: headers
        )
    }

    public func getDedicatedIP(countryCode: String, regionName: String) async throws -> DedicatedIPTokenDetails {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Token \(apiToken)"]
        let requestBody = GetDedicatedIPTokenRequest(countryCode: countryCode, region: regionName)
        let bodyData = try JSONEncoder.piaCodable.encode(requestBody)

        return try await endpointManager.executeWithFailover(
            path: .getDedicatedIP,
            method: .post,
            bodyType: .json(bodyData),
            headers: headers
        )
    }

    public func redeemDedicatedIPs(dipTokens: [String]) async throws -> [DedicatedIPInformation] {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        // Use Token authorization header (matching Kotlin Account.kt line 836)
        let headers = ["Authorization": "Token \(apiToken)"]
        let bodyData = try JSONEncoder.piaCodable.encode(["tokens": dipTokens])

        let response: DedicatedIPInformationResponse = try await endpointManager.executeWithFailover(
            path: .dedicatedIP,
            method: .post,
            bodyType: .json(bodyData),
            headers: headers
        )

        return response.result
    }

    public func renewDedicatedIP(ipToken: String) async throws -> DedicatedIPInformation {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]
        let bodyData = try JSONEncoder.piaCodable.encode(["token": ipToken])

        return try await endpointManager.executeWithFailover(
            path: .renewDedicatedIP,
            method: .post,
            bodyType: .json(bodyData),
            headers: headers
        )
    }

    // MARK: - Subscriptions (iOS)

    public func subscriptions(receipt: Data?) async throws -> IOSSubscriptionInformation {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]

        var bodyDict: [String: String] = ["store": "apple_app_store"]
        if let receipt = receipt {
            bodyDict["receipt"] = receipt.base64EncodedString()
        }
        let bodyData = try JSONEncoder.piaCodable.encode(bodyDict)

        return try await endpointManager.executeWithFailover(
            path: .iosSubscriptions,
            method: .post,
            bodyType: .json(bodyData),
            headers: headers
        )
    }

    // MARK: - Payment (iOS)

    public func payment(username: String, password: String, information: IOSPaymentInformation) async throws {
        let formParams = [
            "username": username,
            "password": password
        ]

        // Encode payment information to JSON, then combine with form params
        let bodyData = try JSONEncoder.piaCodable.encode(information)
        guard let bodyDict = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
            throw PIAAccountError.encodingFailed(
                NSError(domain: "PIAAccount", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize payment information"])
            )
        }

        var combinedParams = formParams
        for (key, value) in bodyDict {
            combinedParams[key] = "\(value)"
        }

        try await endpointManager.executeVoidWithFailover(
            path: .iosPayment,
            method: .post,
            bodyType: .formEncoded(combinedParams)
        )
    }

    // MARK: - Sign Up

    public func signUp(information: IOSSignupInformation) async throws -> VpnSignUpInformation {
        let bodyData = try JSONEncoder.piaCodable.encode(information)

        return try await endpointManager.executeWithFailover(
            path: .signup,
            method: .post,
            bodyType: .json(bodyData)
        )
    }

    // MARK: - Social

    public func sendInvite(email: String, name: String) async throws {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]
        let formParams = [
            "invitee_email": email,
            "invitee_name": name
        ]

        try await endpointManager.executeVoidWithFailover(
            path: .invites,
            method: .post,
            bodyType: .formEncoded(formParams),
            headers: headers
        )
    }

    public func invitesDetails() async throws -> InvitesDetailsInformation {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]

        return try await endpointManager.executeWithFailover(
            path: .invites,
            method: .get,
            headers: headers
        )
    }

    // MARK: - Promotions

    public func redeem(email: String, code: String) async throws -> RedeemInformation {
        let formParams = [
            "email": email,
            "code": code
        ]

        return try await endpointManager.executeWithFailover(
            path: .redeem,
            method: .post,
            bodyType: .formEncoded(formParams)
        )
    }

    // MARK: - Feature Management

    public func message(appVersion: String) async throws -> MessageInformation {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        // Use Token authorization header (matching Kotlin Account.kt line 1506)
        let headers = ["Authorization": "Token \(apiToken)"]

        // Use query parameters (matching Kotlin Account.kt line 1507-1508)
        let queryParams = [
            "client": "ios",
            "version": appVersion
        ]

        return try await endpointManager.executeWithFailover(
            path: .messages,
            method: .get,
            headers: headers,
            queryParameters: queryParams
        )
    }

    public func featureFlags() async throws -> FeatureFlagsInformation {
        try await refreshTokensIfNeeded()

        return try await endpointManager.executeWithFailover(
            path: .iosFeatureFlag,
            method: .get
        )
    }

    // MARK: - Token Refresh Logic

    private func refreshTokensIfNeeded() async throws {
        let (apiNeedsRefresh, vpnNeedsRefresh) = try await tokenManager.needsTokenRefresh()

        if apiNeedsRefresh {
            try await refreshAPIToken()
        }

        if vpnNeedsRefresh {
            try await refreshVPNToken()
        }
    }

    private func refreshAPIToken() async throws {
        guard let currentAPIToken = try await tokenManager.getAPITokenString() else {
            return
        }

        let headers = ["Authorization": "Bearer \(currentAPIToken)"]

        let newTokenResponse: APITokenResponse = try await endpointManager.executeWithFailover(
            path: .refreshAPIToken,
            method: .get,
            headers: headers
        )

        try await tokenManager.storeAPIToken(newTokenResponse)
    }

    private func refreshVPNToken() async throws {
        guard let apiToken = try await tokenManager.getAPITokenString() else {
            return
        }

        let headers = ["Authorization": "Token \(apiToken)"]

        let vpnTokenResponse: VPNTokenResponse = try await endpointManager.executeWithFailover(
            path: .vpnToken,
            method: .post,
            headers: headers
        )

        try await tokenManager.storeVPNToken(vpnTokenResponse)
    }
}
