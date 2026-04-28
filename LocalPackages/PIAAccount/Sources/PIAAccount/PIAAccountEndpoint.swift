import Foundation

/// Protocol for providing account API endpoints
public protocol PIAAccountEndpointProvider: Sendable {
    /// Returns the list of account endpoints to try (in order)
    func accountEndpoints() -> [PIAAccountEndpoint]
}

/// Represents an account API endpoint configuration
public struct PIAAccountEndpoint: Sendable {
    /// The IP address or root domain
    public let ipOrRootDomain: String

    /// Whether this endpoint is a proxy (excluded from client status checks)
    public let isProxy: Bool

    /// Whether to use certificate pinning for this endpoint
    public let usePinnedCertificate: Bool

    /// Optional common name for certificate validation
    public let certificateCommonName: String?

    public init(
        ipOrRootDomain: String,
        isProxy: Bool,
        usePinnedCertificate: Bool = false,
        certificateCommonName: String? = nil
    ) {
        self.ipOrRootDomain = ipOrRootDomain
        self.isProxy = isProxy
        self.usePinnedCertificate = usePinnedCertificate
        self.certificateCommonName = certificateCommonName
    }
}
