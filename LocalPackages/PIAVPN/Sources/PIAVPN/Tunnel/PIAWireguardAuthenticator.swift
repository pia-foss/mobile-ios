import CryptoKit
import Foundation
import KapeVPN_PacketTunnel
import NWHttpConnection
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
        let host = config.authIp.hostLiteral
        // Note: deliberately not logging the token or private key — these are secrets.
        logger.debug("Key-exchange endpoint: \(host):\(config.authPort)")

        guard
            let encodedPubkey = publicKeyBase64.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved),
            let encodedToken = token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved),
            let url = URL(string: "https://\(host):\(config.authPort)/addKey?pubkey=\(encodedPubkey)&pt=\(encodedToken)")
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
            timeout: 10)
        let connection = NWHttpConnectionFactory.makeNWHttpConnection(with: configuration)

        logger.debug("Sending addKey request to \(host):\(config.authPort)")
        let httpResponse: NWHttpConnectionDataResponseType
        do {
            httpResponse = try await connection.singleResponse()
        } catch {
            logger.error("addKey request to \(host) failed: \(String(describing: error))")
            throw error
        }

        let statusCode = httpResponse.statusCode ?? -1

        guard let resultData = httpResponse.data else {
            logger.error("addKey to \(host):\(config.authPort) rejected — http \(statusCode), no JSON body")
            throw PIAWireguardAuthError.serverError("http \(statusCode): no JSON body")
        }

        let response: WGKeyResponse
        do {
            response = try JSONDecoder().decode(WGKeyResponse.self, from: resultData)
        } catch {
            let detail = errorDetail(in: resultData, redacting: token)
            logger.error("addKey to \(host):\(config.authPort) rejected — http \(statusCode), \(detail)")
            throw PIAWireguardAuthError.serverError("http \(statusCode): \(detail)")
        }
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
        let dnsServers = rawDnsServers.map(IpAddress.init(parsing:))

        // Enrich the endpoint config with the post-auth state, per `PacketTunnelWireguardAuthenticator`.
        var authenticated = config
        authenticated.serverPublicKey = response.server_key
        authenticated.clientPrivateKey = privateKeyBase64
        authenticated.internalIp = response.peer_ip
        authenticated.dnsServers = dnsServers
        return authenticated
    }

    private func errorDetail(in data: Data, redacting token: String) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "\(data.count) byte(s), body is not a JSON object"
        }

        let secrets = [token, token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)].compactMap { $0 }

        return
            object
            .sorted { $0.key < $1.key }
            .map { key, value in
                var text = String(describing: value)
                for secret in secrets {
                    text = text.replacingOccurrences(of: secret, with: "<redacted>")
                }
                return "\(key)=\(text)"
            }
            .joined(separator: ", ")
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
