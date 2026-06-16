import CryptoKit
import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

final class PIAWireguardAuthenticator: PacketTunnelWireguardAuthenticator, Sendable {
    private let logger = PIATunnelLogger(label: "PIAWireguardAuthenticator")

    func authenticate(config: WireguardEndpointConfiguration) async throws -> WireguardAuthConfiguration {
        logger.info("Authenticating WireGuard key with server")

        guard let token = Client.providers.accountProvider.vpnToken else {
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

        let delegate = TrustAllCertsDelegate()
        let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)

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
        return WireguardAuthConfiguration(
            psk: "",
            serverPublicKey: response.server_key,
            clientPrivateKey: privateKeyBase64,
            internalIp: response.peer_ip
        )
    }
}

private enum PIAWireguardAuthError: Error {
    case noToken
    case invalidURL
    case serverError(String)
}

private struct WGKeyResponse: Decodable {
    let status: String
    let server_key: String
    let peer_ip: String
}

// TODO: [PlatformSDK] Temporary — replace with proper certificate/SPKI pinning against the VPN
// server's cert. Trusting all certs is a placeholder and must not ship.
// VPN server endpoint uses a self-signed cert; standard practice for tunnel auth.
private final class TrustAllCertsDelegate: NSObject, URLSessionDelegate, Sendable {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}
