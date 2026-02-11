import Foundation

/// Main implementation of PIAAccountAPI
public final class PIAAccountClient: PIAAccountAPI {
    private let endpointManager: EndpointManager
    private let tokenManager: TokenManager
    private let userAgent: String

    // Cached tokens for synchronous access
    private var cachedAPIToken: String?
    private var cachedVPNToken: String?
    private let tokenQueue = DispatchQueue(label: "com.pia.account.tokens")

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

        // Load cached tokens on init
        Task {
            await self.updateCachedTokens()
        }
    }

    // MARK: - Token Access

    public var apiToken: String? {
        tokenQueue.sync { cachedAPIToken }
    }

    public var vpnToken: String? {
        tokenQueue.sync { cachedVPNToken }
    }

    private func updateCachedTokens() async {
        let apiToken = try? await tokenManager.getAPITokenString()
        let vpnToken = try? await tokenManager.getVPNToken()

        tokenQueue.sync {
            self.cachedAPIToken = apiToken
            self.cachedVPNToken = vpnToken
        }
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

        // Update cached tokens
        await updateCachedTokens()
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

        // Update cached tokens
        await updateCachedTokens()
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
        let formParams = ["token": apiToken]

        let apiTokenResponse: APITokenResponse = try await endpointManager.executeWithFailover(
            path: .login,
            method: .post,
            bodyType: .formEncoded(formParams)
        )

        try await tokenManager.storeAPIToken(apiTokenResponse)
        try await refreshVPNToken()
    }

    public func logout() async throws {
        // Get API token for logout request
        guard let apiToken = try await tokenManager.getAPITokenString() else {
            // No token to logout - just clear local storage
            try await tokenManager.clearAllTokens()
            await updateCachedTokens()
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

        // Update cached tokens
        await updateCachedTokens()
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
        await updateCachedTokens()
    }

    public func clientStatus() async throws -> ClientStatusInformation {
        return try await endpointManager.executeWithFailover(
            path: .clientStatus,
            method: .get
        )
    }

    // MARK: - Email Management

    public func setEmail(email: String, resetPassword: Bool) async throws {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]
        let formParams = [
            "email": email,
            "reset_password": resetPassword ? "true" : "false"
        ]

        try await endpointManager.executeVoidWithFailover(
            path: .setEmail,
            method: .post,
            bodyType: .formEncoded(formParams),
            headers: headers
        )
    }

    public func setEmail(username: String, password: String, email: String, resetPassword: Bool) async throws {
        let formParams = [
            "username": username,
            "password": password,
            "email": email,
            "reset_password": resetPassword ? "true" : "false"
        ]

        try await endpointManager.executeVoidWithFailover(
            path: .setEmail,
            method: .post,
            bodyType: .formEncoded(formParams)
        )
    }

    // MARK: - Dedicated IP

    public func dedicatedIPs(ipTokens: [String]) async throws -> [DedicatedIPInformation] {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]
        let bodyData = try JSONEncoder.piaCodable.encode(["tokens": ipTokens])

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

    public func subscriptions(receipt: String) async throws -> IOSSubscriptionInformation {
        try await refreshTokensIfNeeded()

        guard let apiToken = try await tokenManager.getAPITokenString() else {
            throw PIAAccountError.unauthorized()
        }

        let headers = ["Authorization": "Bearer \(apiToken)"]
        let bodyData = try JSONEncoder.piaCodable.encode([
            "store": "apple_app_store",
            "receipt": receipt
        ])

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

    public func signUp(information: IOSSignupInformation) async throws -> SignUpInformation {
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
        // Build URL with query parameter
        // Note: This requires a custom implementation since we need to add query params
        let formParams = ["version": appVersion]

        return try await endpointManager.executeWithFailover(
            path: .messages,
            method: .post,
            bodyType: .formEncoded(formParams)
        )
    }

    public func featureFlags() async throws -> FeatureFlagsInformation {
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
        try await tokenManager.refreshAPITokenIfNeeded {
            guard let currentAPIToken = try await self.tokenManager.getAPITokenString() else {
                return
            }

            let headers = ["Authorization": "Bearer \(currentAPIToken)"]

            let newTokenResponse: APITokenResponse = try await self.endpointManager.executeWithFailover(
                path: .refreshAPIToken,
                method: .get,
                headers: headers
            )

            try await self.tokenManager.storeAPIToken(newTokenResponse)
        }
    }

    private func refreshVPNToken() async throws {
        try await tokenManager.refreshVPNTokenIfNeeded {
            guard let apiToken = try await self.tokenManager.getAPITokenString() else {
                return
            }

            let headers = ["Authorization": "Token \(apiToken)"]

            let vpnTokenResponse: VPNTokenResponse = try await self.endpointManager.executeWithFailover(
                path: .vpnToken,
                method: .post,
                headers: headers
            )

            try await self.tokenManager.storeVPNToken(vpnTokenResponse)
        }
    }
}
