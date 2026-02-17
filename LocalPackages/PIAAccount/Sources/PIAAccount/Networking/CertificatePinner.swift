import Foundation
import Security

/// URLSession delegate that performs SSL certificate pinning
final class CertificatePinner: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let certificateData: Data
    private let hostname: String?
    private let commonName: String?

    /// Creates a certificate pinner
    /// - Parameters:
    ///   - certificate: PEM-encoded certificate string
    ///   - hostname: Optional hostname to validate
    ///   - commonName: Optional common name to validate
    init(certificate: String, hostname: String? = nil, commonName: String? = nil) {
        // Strip PEM headers and newlines, then base64 decode
        let cleanedCertificate = certificate
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")

        guard let data = Data(base64Encoded: cleanedCertificate) else {
            fatalError("Invalid certificate data - failed to base64 decode")
        }

        self.certificateData = data
        self.hostname = hostname
        self.commonName = commonName
        super.init()
    }

    // MARK: - URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Only handle server trust authentication
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Get the server's certificate (first in chain)
        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Validate hostname if specified
        if let expectedHostname = hostname {
            let actualHostname = challenge.protectionSpace.host
            guard actualHostname == expectedHostname else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
        }

        // Validate common name if specified
        if let expectedCommonName = commonName {
            var commonNameRef: CFString?
            let status = SecCertificateCopyCommonName(serverCertificate, &commonNameRef)

            guard status == errSecSuccess,
                  let actualCommonName = commonNameRef as String?,
                  actualCommonName == expectedCommonName else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
        }

        // Create pinned certificate from our certificate data
        guard let pinnedCertificate = SecCertificateCreateWithData(nil, certificateData as CFData) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Create SSL policy
        let policy = SecPolicyCreateSSL(true, nil)

        // Create trust object with server certificate and policy
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(
            serverCertificate,
            policy,
            &trust
        )

        guard trustCreationStatus == errSecSuccess, let trust = trust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Set our pinned certificate as the anchor (trusted root)
        let anchorCertificates = [pinnedCertificate] as CFArray
        let anchorStatus = SecTrustSetAnchorCertificates(trust, anchorCertificates)

        guard anchorStatus == errSecSuccess else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Evaluate the trust (this performs the actual validation)
        var error: CFError?
        let evaluationSucceeded = SecTrustEvaluateWithError(trust, &error)

        if evaluationSucceeded {
            // Certificate validation succeeded - accept the challenge
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Certificate validation failed - reject the challenge
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
