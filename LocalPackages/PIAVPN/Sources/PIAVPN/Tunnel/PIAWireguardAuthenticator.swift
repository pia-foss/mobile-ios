import CryptoKit
import Foundation
import KapeVPN_PacketTunnel
import NWHttpConnection
import PIALibrary

final class PIAWireguardAuthenticator: PacketTunnelWireguardAuthenticator, Sendable {
    static let keyExchangeTimeout: TimeInterval = 10

    private let logger = PIATunnelLogger(label: "PIAWireguardAuthenticator")

    func authenticate(config: WireguardEndpointConfiguration) async throws -> WireguardEndpointConfiguration {
        // AmneziaWG servers serve their key exchange on their own path and port.
        let isAmnezia =
            if case .amnezia = config.obfuscation {
                true
            } else {
                false
            }

        let label = isAmnezia ? "AmneziaWG" : "WireGuard"
        let path = isAmnezia ? "add-awg-key" : "addKey"

        logger.info(
            "Authenticating \(label) key with server — tunnel endpoint: \(config.ip.hostLiteral):\(config.port), "
                + "key exchange: \(config.authIp.hostLiteral):\(config.authPort), expected cn: \(config.certDn)"
        )

        let sharedState = PIATunnelSharedState.read()

        // Prefer the token the app resolved at connect time (carried in shared state): the account
        // `vpnToken` for a regular server, or the server's `dipUsername` for a Dedicated IP server.
        // Fall back to the account token in case shared state predates this field.
        let tokenSource: String
        let resolvedToken: String?
        if let sharedToken = sharedState.wireGuard.token {
            tokenSource = sharedState.selectedDipServer != nil ? "shared state (dedicated IP)" : "shared state (account)"
            resolvedToken = sharedToken
        } else {
            tokenSource = "account provider fallback"
            resolvedToken = Client.providers.accountProvider.vpnToken
        }
        guard let token = resolvedToken, !token.isEmpty else {
            logger.error("No VPN token available (source: \(tokenSource)) — cannot authenticate")
            throw PIAWireguardAuthError.noToken
        }
        logger.debug("Token source: \(tokenSource), length: \(token.count)")
        let secrets = [token]

        // Ephemeral key pair per connection — WireGuard's forward-secrecy model.
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKeyBase64 = privateKey.publicKey.rawRepresentation.base64EncodedString()
        let privateKeyBase64 = privateKey.rawRepresentation.base64EncodedString()

        // authIp/authPort is the HTTP key-exchange endpoint, distinct from the WireGuard UDP endpoint (ip/port).
        let host = config.authIp.hostLiteral
        // Note: deliberately not logging the token or private key — these are secrets.
        logger.debug(
            "Key-exchange request: GET https://\(host):\(config.authPort)/\(path)?pubkey=\(publicKeyBase64)&pt=<redacted>, "
                + "timeout: \(Int(Self.keyExchangeTimeout))s"
        )

        guard
            let encodedPubkey = publicKeyBase64.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved),
            let encodedToken = token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved),
            let url = URL(string: "https://\(host):\(config.authPort)/\(path)?pubkey=\(encodedPubkey)&pt=\(encodedToken)")
        else {
            logger.error("Failed to build key-exchange URL for \(host):\(config.authPort)")
            throw PIAWireguardAuthError.invalidURL
        }

        // Pin the key-exchange TLS connection against the bundled PIA root CA, validating that the
        // server's leaf certificate is anchored to it and its Common Name matches the per-server
        // `certDn` the app resolved. The endpoint is reached by IP with a self-signed cert, so this
        // mirrors the legacy WireGuard pinning (anchor + CN, no hostname check). Fail closed.
        guard let anchorCertificate = AnchorCertificateProvider.getAnchorCertificate() else {
            logger.error("Failed to load PIA anchor certificate — cannot pin key-exchange connection")
            throw PIAWireguardAuthError.missingAnchorCertificate
        }

        let configuration = NWConnectionConfiguration(
            url: url,
            method: .get,
            body: nil,
            certificateValidation: .anchor(certificate: anchorCertificate, commonName: config.certDn),
            dataResponseType: .jsonData,
            timeout: Self.keyExchangeTimeout)
        let connection = NWHttpConnectionFactory.makeNWHttpConnection(with: configuration)

        let start = Date()
        let httpResponse: NWHttpConnectionDataResponseType
        do {
            httpResponse = try await connection.singleResponse()
        } catch {
            let elapsedMs = PIATunnelDiagnostics.elapsedMs(since: start)
            logger.error(
                "\(path) request to \(host):\(config.authPort) failed after \(elapsedMs)ms "
                    + "(\(Self.failureHint(for: error, elapsedMs: elapsedMs))): "
                    + PIATunnelDiagnostics.redact(PIATunnelDiagnostics.describe(error), secrets: secrets)
            )
            throw error
        }

        let elapsedMs = PIATunnelDiagnostics.elapsedMs(since: start)
        let statusCode = httpResponse.statusCode ?? -1

        guard let resultData = httpResponse.data else {
            logger.error("\(path) to \(host):\(config.authPort) rejected after \(elapsedMs)ms — http \(statusCode), no JSON body")
            throw PIAWireguardAuthError.serverError("http \(statusCode): no JSON body")
        }

        let detail = PIATunnelDiagnostics.payload(resultData, redacting: secrets)
        logger.debug("\(path) response from \(host):\(config.authPort) after \(elapsedMs)ms — http \(statusCode), \(detail)")

        let response: WGKeyResponse
        do {
            response = try JSONDecoder().decode(WGKeyResponse.self, from: resultData)
        } catch {
            logger.error("\(path) to \(host):\(config.authPort) rejected — http \(statusCode), \(detail)")
            throw PIAWireguardAuthError.serverError("http \(statusCode): \(detail)")
        }
        guard response.status == "OK" else {
            logger.error("Key-exchange server returned non-OK status: \(response.status) (http \(statusCode)), \(detail)")
            throw PIAWireguardAuthError.serverError(response.status)
        }

        logger.info("\(label) authentication succeeded in \(elapsedMs)ms (peer ip: \(response.peer_ip))")

        if let echoed = response.peer_pubkey, echoed != publicKeyBase64 {
            logger.warning("Key-exchange server echoed a different public key than the one sent")
        }

        // Resolve the DNS the tunnel should use. The user's custom DNS choice (Settings → Network),
        // carried in shared state, takes precedence. When the user kept the PIA default the list is
        // empty, so fall back to the server-provided resolvers — these make the tunnel use PIA's real
        // DNS rather than the SDK's `transformToDns(internalIP)` heuristic, which is wrong for pools
        // whose resolver isn't at `<a>.<b>.0.1` (e.g. Dedicated IP). Empty here → SDK heuristic.
        let customDnsServers = sharedState.wireGuard.dnsServers
        let rawDnsServers = customDnsServers.isEmpty ? (response.dns_servers ?? []) : customDnsServers
        if !customDnsServers.isEmpty {
            logger.info("Using \(customDnsServers.count) user-selected DNS resolver(s) for WireGuard: \(customDnsServers.joined(separator: ", "))")
        } else if !rawDnsServers.isEmpty {
            logger.info("Using server-provided DNS for WireGuard: \(rawDnsServers.joined(separator: ", "))")
        } else {
            logger.warning("No DNS from user or server — the SDK will derive it from the peer ip")
        }
        let dnsServers = rawDnsServers.map(IpAddress.init(parsing:))

        // Enrich the endpoint config with the post-auth state, per `PacketTunnelWireguardAuthenticator`.
        var authenticated = config
        authenticated.serverPublicKey = response.server_key
        authenticated.clientPrivateKey = privateKeyBase64
        authenticated.internalIp = response.peer_ip
        authenticated.dnsServers = dnsServers

        // The endpoint was built with placeholder parameters; only the server knows the real ones, so
        // an amnezia endpoint that gets none back must fail rather than connect with the placeholder.
        if isAmnezia {
            guard let obfuscation = response.obfuscation else {
                logger.error("AmneziaWG key exchange returned no obfuscation parameters")
                throw PIAWireguardAuthError.missingObfuscation
            }
            authenticated.obfuscation = obfuscation.asWireguardObfuscation
            logger.info("AmneziaWG obfuscation resolved — \(obfuscation.summary)")
        }

        return authenticated
    }

    static func failureHint(for error: Error, elapsedMs: Int) -> String {
        if case NWHttpConnectionError.connection(.tls(_)) = error {
            return "TLS pinning failure"
        }
        if case NWHttpConnectionError.wait(.tls(_)) = error {
            return "TLS pinning failure"
        }
        if elapsedMs >= Int(keyExchangeTimeout * 1000) {
            return "likely timeout"
        }
        return "transport error"
    }
}

private enum PIAWireguardAuthError: Error {
    case noToken
    case invalidURL
    case serverError(String)
    case missingAnchorCertificate
    case missingObfuscation
}

struct WGKeyResponse: Decodable {
    let status: String
    let server_key: String
    let peer_ip: String
    let dns_servers: [String]?
    let peer_pubkey: String?
    let obfuscation: WGObfuscationResponse?
}

struct WGObfuscationResponse: Decodable {
    let s1: UInt64
    let s2: UInt64
    let jc: UInt64
    let jmin: UInt64
    let jmax: UInt64
    let h1: UInt64
    let h2: UInt64
    let h3: UInt64
    let h4: UInt64

    var asWireguardObfuscation: WireguardObfuscation {
        .amnezia(s1: s1, s2: s2, jc: jc, jmin: jmin, jmax: jmax, h1: h1, h2: h2, h3: h3, h4: h4)
    }

    var summary: String {
        "s1: \(s1), s2: \(s2), jc: \(jc), jmin: \(jmin), jmax: \(jmax), h1: \(h1), h2: \(h2), h3: \(h3), h4: \(h4)"
    }
}
