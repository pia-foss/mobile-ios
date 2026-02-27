import Foundation

/// Fluent builder for creating PIAAccountAPI instances.
///
/// Use this builder to configure and create a PIAAccountAPI client with custom endpoints,
/// certificate pinning, and user agent settings.
///
/// ## Example
///
/// ```swift
/// // Create an endpoint provider
/// struct MyEndpointProvider: PIAAccountEndpointProvider {
///     func accountEndpoints() -> [PIAAccountEndpoint] {
///         return [
///             PIAAccountEndpoint(
///                 ipOrRootDomain: "privateinternetaccess.com",
///                 isProxy: false,
///                 usePinnedCertificate: true,
///                 certificateCommonName: "*.privateinternetaccess.com"
///             )
///         ]
///     }
/// }
///
/// // Build the client
/// var builder = PIAAccountBuilder()
/// builder.setEndpointProvider(MyEndpointProvider())
/// builder.setCertificate(pemCertificate)
/// builder.setUserAgent("MyApp/1.0")
/// let account = try builder.build()
///
/// // Use async/await API
/// try await account.loginWithCredentials(username: "user", password: "pass")
/// let details = try await account.accountDetails()
/// print("Plan: \(details.plan)")
/// ```
public struct PIAAccountBuilder: Sendable {
    private var endpointProvider: PIAAccountEndpointProvider?
    private var certificate: String?
    private var userAgent: String?

    public init() {}

    /// Sets the endpoint provider
    /// - Parameter provider: The endpoint provider
    /// - Returns: Self for chaining
    @discardableResult
    public mutating func setEndpointProvider(_ provider: PIAAccountEndpointProvider) -> Self {
        self.endpointProvider = provider
        return self
    }

    /// Sets the certificate for SSL pinning
    /// - Parameter certificate: PEM-encoded certificate string
    /// - Returns: Self for chaining
    @discardableResult
    public mutating func setCertificate(_ certificate: String?) -> Self {
        self.certificate = certificate
        return self
    }

    /// Sets the User-Agent header value
    /// - Parameter userAgent: User-Agent string
    /// - Returns: Self for chaining
    @discardableResult
    public mutating func setUserAgent(_ userAgent: String) -> Self {
        self.userAgent = userAgent
        return self
    }

    /// Builds the PIAAccountAPI instance
    /// - Returns: A configured account client
    /// - Throws: PIAAccountError if required parameters are missing
    public func build() throws -> PIAAccountAPI {
        guard let endpointProvider = endpointProvider else {
            throw PIAAccountError.configurationError("Endpoint provider is required")
        }

        guard let userAgent = userAgent else {
            throw PIAAccountError.configurationError("User agent is required")
        }

        return PIAAccountClient(
            endpointProvider: endpointProvider,
            certificate: certificate,
            userAgent: userAgent
        )
    }
}
