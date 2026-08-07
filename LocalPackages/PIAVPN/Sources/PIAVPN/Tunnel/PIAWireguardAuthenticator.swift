import CryptoKit
import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

final class PIAWireguardAuthenticator: PacketTunnelWireguardAuthenticator, Sendable {
    private let logger = PIATunnelLogger(label: "PIAWireguardAuthenticator")

    func authenticate(config: WireguardEndpointConfiguration) async throws -> WireguardEndpointConfiguration {
        logger.info("Authenticating WireGuard key with server")

        let sharedState = PIATunnelSharedState.read()

        // Prefer the token the app resolved at connect time (carried in shared state): the account
        // `vpnToken` for a regular server, or the server's `dipUsername` for a Dedicated IP server.
        // Fall back to the account token in case shared state predates this field.
        guard let token = sharedState.wireGuard.token ?? Client.providers.accountProvider.vpnToken else {
            logger.error("No VPN token available — cannot authenticate")
            throw PIAWireguardAuthError.noToken
        }

        // Ephemeral key pair per connection — WireGuard's forward-secrecy model.
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKeyBase64 = privateKey.publicKey.rawRepresentation.base64EncodedString()
        let privateKeyBase64 = privateKey.rawRepresentation.base64EncodedString()

        // authIp/authPort is the HTTP key-exchange endpoint, distinct from the WireGuard UDP endpoint (ip/port).
        let host: String
        switch config.authIp {
        case .v4(ipV4: let ip):
            host = ip
        case .v6(ipV6: let ip):
            host = "[\(ip)]"
        }
        // Note: deliberately not logging the token or private key — these are secrets.
        logger.debug("Key-exchange endpoint: \(host):\(config.authPort)")

        guard
            let encodedPubkey = publicKeyBase64.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let encodedToken = token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://\(host):\(config.authPort)/addKey?pubkey=\(encodedPubkey)&pt=\(encodedToken)")
        else {
            logger.error("Failed to build key-exchange URL for \(host):\(config.authPort)")
            throw PIAWireguardAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        // Pin the key-exchange TLS connection against the bundled PIA root CA, validating that the
        // server's leaf certificate is anchored to it and its Common Name matches the per-server
        // `certDn` the app resolved. The endpoint is reached by IP with a self-signed cert, so this
        // mirrors the legacy WireGuard pinning (anchor + CN, no hostname check). Fail closed.
        guard let anchorCertificate = AnchorCertificateProvider.getAnchorCertificate() else {
            logger.error("Failed to load PIA anchor certificate — cannot pin key-exchange connection")
            throw PIAWireguardAuthError.missingAnchorCertificate
        }
        let delegate = PinnedCertificateDelegate(
            anchorCertificate: anchorCertificate, expectedCommonName: config.certDn, logger: logger)
        let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)

        defer {
            session.finishTasksAndInvalidate()
        }

        logger.debug("Sending addKey request to \(host):\(config.authPort)")
        let resultData: Data
        do {
            (resultData, _) = try await session.data(for: request)
        } catch {
            logger.error("addKey request to \(host) failed: \(error.localizedDescription)")
            throw error
        }

        let response = try JSONDecoder().decode(WGKeyResponse.self, from: resultData)
        guard response.status == "OK" else {
            logger.error("Key-exchange server returned non-OK status: \(response.status)")
            throw PIAWireguardAuthError.serverError(response.status)
        }

        logger.info("WireGuard authentication succeeded (peer ip: \(response.peer_ip))")

        // Resolve the DNS the tunnel should use. The user's custom DNS choice (Settings → Network),
        // carried in shared state, takes precedence. When the user kept the PIA default the list is
        // empty, so fall back to the server-provided resolvers — these make the tunnel use PIA's real
        // DNS rather than the SDK's `transformToDns(internalIP)` heuristic, which is wrong for pools
        // whose resolver isn't at `<a>.<b>.0.1` (e.g. Dedicated IP). Empty here → SDK heuristic.
        let customDnsServers = sharedState.wireGuard.dnsServers
        let rawDnsServers = customDnsServers.isEmpty ? (response.dns_servers ?? []) : customDnsServers
        if !customDnsServers.isEmpty {
            logger.info("Using \(customDnsServers.count) user-selected DNS resolver(s) for WireGuard")
        }
        let dnsServers: [IpAddress] = rawDnsServers.map {
            $0.contains(":") ? .v6(ipV6: $0) : .v4(ipV4: $0)
        }

        // Enrich the endpoint config with the post-auth state, per `PacketTunnelWireguardAuthenticator`.
        var authenticated = config
        authenticated.serverPublicKey = response.server_key
        authenticated.clientPrivateKey = privateKeyBase64
        authenticated.internalIp = response.peer_ip
        authenticated.dnsServers = dnsServers
        return authenticated
    }
}

private enum PIAWireguardAuthError: Error {
    case noToken
    case invalidURL
    case serverError(String)
    case missingAnchorCertificate
}

private struct WGKeyResponse: Decodable {
    let status: String
    let server_key: String
    let peer_ip: String
    let dns_servers: [String]?
}

/// `URLSessionDelegate` that pins the key-exchange TLS connection to the bundled PIA root CA.
///
/// The VPN server is reached by IP and presents a self-signed leaf signed by the PIA CA, so the
/// system trust chain can't validate it. We instead require the leaf's Common Name to match the
/// per-server `certDn` and the leaf to chain to the pinned anchor. Mirrors the legacy WireGuard
/// pinning (`CertificateValidation.anchor`) and PIAAccount's `CertificatePinner`. Fails closed:
/// any mismatch or evaluation failure cancels the challenge.
///
/// The anchor is stored as immutable DER `Data` (not a `SecCertificate`) so the type is cleanly
/// `Sendable`; the `SecCertificate` is rebuilt inside the callback.
private final class PinnedCertificateDelegate: NSObject, URLSessionDelegate, Sendable {
    private let anchorCertificateData: Data
    private let expectedCommonName: String
    private let logger: PIATunnelLogger

    init(anchorCertificate: SecCertificate, expectedCommonName: String, logger: PIATunnelLogger) {
        self.anchorCertificateData = SecCertificateCopyData(anchorCertificate) as Data
        self.expectedCommonName = expectedCommonName
        self.logger = logger
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            let leafCertificate = (SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate])?.first
        else {
            logger.error("Pinning failed: no server trust on key-exchange challenge")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // The leaf's CN must match the per-server `certDn`.
        var leafCommonName: CFString?
        SecCertificateCopyCommonName(leafCertificate, &leafCommonName)
        guard let leafCommonName = leafCommonName as String?, leafCommonName == expectedCommonName else {
            logger.error(
                "Pinning failed: leaf CN \"\(leafCommonName as String? ?? "nil")\" != expected \"\(expectedCommonName)\"")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Rebuild trust on the leaf with the pinned PIA CA as the sole anchor, then evaluate.
        // No hostname check: the endpoint is an IP, so the SSL policy is created with a nil host.
        guard let anchorCertificate = SecCertificateCreateWithData(nil, anchorCertificateData as CFData) else {
            logger.error("Pinning failed: could not decode anchor certificate")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var trust: SecTrust?
        guard SecTrustCreateWithCertificates(leafCertificate, SecPolicyCreateSSL(true, nil), &trust) == errSecSuccess,
            let trust,
            SecTrustSetAnchorCertificates(trust, [anchorCertificate] as CFArray) == errSecSuccess,
            SecTrustSetAnchorCertificatesOnly(trust, true) == errSecSuccess
        else {
            logger.error("Pinning failed: could not build trust for evaluation")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var error: CFError?
        guard SecTrustEvaluateWithError(trust, &error) else {
            logger.error("Pinning failed: trust evaluation rejected the server certificate")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
