import Foundation

public struct KPIEndpoint: Sendable {
    public let endpoint: String
    public let usePinnedCertificate: Bool
    public let certificateCommonName: String?

    public init(
        endpoint: String,
        usePinnedCertificate: Bool = false,
        certificateCommonName: String? = nil
    ) {
        self.endpoint = endpoint
        self.usePinnedCertificate = usePinnedCertificate
        self.certificateCommonName = certificateCommonName
    }
}
