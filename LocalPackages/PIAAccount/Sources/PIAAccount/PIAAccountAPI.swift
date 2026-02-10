import Foundation

/// Main API protocol for PIA Account operations.
///
/// This protocol defines all account management operations for Private Internet Access,
/// including authentication, account management, subscriptions, and feature access.
///
/// ## Token Management
///
/// After successful login, API and VPN tokens are securely stored in the Keychain and
/// cached for synchronous access via the `apiToken` and `vpnToken` properties.
///
/// Tokens are automatically refreshed when they expire within 21 days, ensuring
/// uninterrupted service. All authenticated requests check token expiration and
/// refresh if needed before making API calls.
///
/// ## Threading
///
/// All async methods are safe to call from any thread. The token cache properties
/// (`apiToken`, `vpnToken`) use thread-safe access and can be read from any queue.
///
/// ## Error Handling
///
/// All methods that can fail throw `PIAAccountError`, which includes:
/// - HTTP status codes (401 = unauthorized, 500 = server error, etc.)
/// - Network failures (600+)
/// - Custom error messages from the API when available
///
/// For operations that try multiple endpoints, `PIAMultipleErrors` aggregates
/// all failures if none succeed.
public protocol PIAAccountAPI {
    // MARK: - Token Access

    /// Returns the cached API token, if available.
    ///
    /// This property provides synchronous access to the API token that was obtained
    /// during login. The token is cached from the Keychain for performance.
    ///
    /// - Returns: The API token string, or `nil` if not logged in
    var apiToken: String? { get }

    /// Returns the cached VPN token in "vpn_token_{username}:{password}" format, if available.
    ///
    /// This property provides synchronous access to the VPN authentication token.
    /// The format is required for VPN server authentication.
    ///
    /// - Returns: The formatted VPN token string, or `nil` if not logged in
    var vpnToken: String? { get }

    // MARK: - Authentication

    /// Authenticates with username and password credentials.
    ///
    /// On success, API and VPN tokens are obtained and stored securely in the Keychain.
    /// The tokens are also cached for synchronous access via `apiToken` and `vpnToken`.
    ///
    /// - Parameters:
    ///   - username: The PIA account username
    ///   - password: The PIA account password
    /// - Throws: `PIAAccountError` with code 401 if credentials are invalid,
    ///           or network/server errors for other failures
    func loginWithCredentials(username: String, password: String) async throws

    /// Authenticates with an App Store receipt (iOS-specific).
    ///
    /// Use this method to authenticate users who have purchased a subscription
    /// through the iOS App Store. The receipt is validated server-side.
    ///
    /// - Parameter receiptBase64: Base64-encoded App Store receipt obtained from
    ///                            `Bundle.main.appStoreReceiptURL`
    /// - Throws: `PIAAccountError` with code 400 if receipt is invalid,
    ///           401 if subscription is not active, or network/server errors
    func loginWithReceipt(receiptBase64: String) async throws

    /// Sends a login link via email.
    ///
    /// Sends a magic login link to the specified email address. The user can
    /// click the link to authenticate without entering credentials.
    ///
    /// - Parameter email: Email address to send the login link to
    /// - Throws: `PIAAccountError` with code 404 if email not found,
    ///           or network/server errors
    func loginLink(email: String) async throws

    /// Migrates an existing API token from a previous session or device.
    ///
    /// Use this to restore authentication when you have a valid API token
    /// from a previous session. The token will be validated and a new VPN token obtained.
    ///
    /// - Parameter apiToken: The API token to migrate
    /// - Throws: `PIAAccountError` with code 401 if token is invalid or expired
    func migrateApiToken(apiToken: String) async throws

    /// Logs out and clears all stored tokens.
    ///
    /// Sends a logout request to the server (best effort) and clears tokens from
    /// the Keychain. Even if the server request fails, local tokens are cleared.
    ///
    /// After logout, `apiToken` and `vpnToken` will return `nil`.
    ///
    /// - Throws: Typically does not throw - errors are swallowed since cleanup
    ///           always proceeds regardless of server response
    func logout() async throws

    // MARK: - Account Management

    /// Retrieves current account details
    /// - Returns: Account information
    /// - Throws: PIAAccountError if the request fails
    func accountDetails() async throws -> AccountInformation

    /// Deletes the current account
    /// - Throws: PIAAccountError if deletion fails
    func deleteAccount() async throws

    /// Retrieves client connection status
    /// - Returns: Client status information
    /// - Throws: PIAAccountError if the request fails
    func clientStatus() async throws -> ClientStatusInformation

    // MARK: - Email Management

    /// Sets or updates the account email
    /// - Parameters:
    ///   - email: New email address
    ///   - resetPassword: Whether to trigger password reset
    /// - Throws: PIAAccountError if the request fails
    func setEmail(email: String, resetPassword: Bool) async throws

    /// Sets or updates the account email (iOS-specific with credentials)
    /// - Parameters:
    ///   - username: Account username
    ///   - password: Account password
    ///   - email: New email address
    ///   - resetPassword: Whether to trigger password reset
    /// - Throws: PIAAccountError if the request fails
    func setEmail(username: String, password: String, email: String, resetPassword: Bool) async throws

    // MARK: - Dedicated IP

    /// Retrieves dedicated IP information
    /// - Parameter ipTokens: Array of IP tokens to query
    /// - Returns: Array of dedicated IP information
    /// - Throws: PIAAccountError if the request fails
    func dedicatedIPs(ipTokens: [String]) async throws -> [DedicatedIPInformation]

    /// Renews a dedicated IP
    /// - Parameter ipToken: The IP token to renew
    /// - Returns: Updated dedicated IP information
    /// - Throws: PIAAccountError if renewal fails
    func renewDedicatedIP(ipToken: String) async throws -> DedicatedIPInformation

    // MARK: - Subscriptions (iOS)

    /// Retrieves iOS subscription information
    /// - Parameter receipt: Base64-encoded App Store receipt
    /// - Returns: Subscription information
    /// - Throws: PIAAccountError if the request fails
    func subscriptions(receipt: String) async throws -> IOSSubscriptionInformation

    // MARK: - Payment (iOS)

    /// Updates payment information
    /// - Parameters:
    ///   - username: Account username
    ///   - password: Account password
    ///   - information: Payment information
    /// - Throws: PIAAccountError if the update fails
    func payment(username: String, password: String, information: IOSPaymentInformation) async throws

    // MARK: - Sign Up

    /// Creates a new account
    /// - Parameter information: Sign up information
    /// - Returns: New account credentials
    /// - Throws: PIAAccountError if sign up fails
    func signUp(information: IOSSignupInformation) async throws -> SignUpInformation

    // MARK: - Social

    /// Sends an invite to an email address
    /// - Parameters:
    ///   - email: Recipient email address
    ///   - name: Recipient name
    /// - Throws: PIAAccountError if the request fails
    func sendInvite(email: String, name: String) async throws

    /// Retrieves invitation/referral details
    /// - Returns: Invites details information
    /// - Throws: PIAAccountError if the request fails
    func invitesDetails() async throws -> InvitesDetailsInformation

    // MARK: - Promotions

    /// Redeems a gift card or promo code
    /// - Parameters:
    ///   - email: Email address for redemption
    ///   - code: Gift card or promo code
    /// - Returns: Redemption information
    /// - Throws: PIAAccountError if redemption fails
    func redeem(email: String, code: String) async throws -> RedeemInformation

    // MARK: - Feature Management

    /// Retrieves in-app messages
    /// - Parameter appVersion: Application version string
    /// - Returns: Message information
    /// - Throws: PIAAccountError if the request fails
    func message(appVersion: String) async throws -> MessageInformation

    /// Retrieves feature flags
    /// - Returns: Feature flags information
    /// - Throws: PIAAccountError if the request fails
    func featureFlags() async throws -> FeatureFlagsInformation
}
