import Foundation
import KapeVPN_PacketTunnel
import NWHttpConnection
import Network
import Testing

@testable import PIAVPN

@Suite("Tunnel diagnostics formatting")
struct PIATunnelDiagnosticsTests {

    @Test("NWError codes are spelled out")
    func posixCode() {
        let text = PIATunnelDiagnostics.describe(NWHttpConnectionError.wait(.posix(.ECONNREFUSED)))
        #expect(text == "wait(posix 61 Connection refused)")
    }

    @Test("badURL never prints the URL, which carries the token")
    func badURLRedacted() throws {
        let url = try #require(URL(string: "https://1.2.3.4:1337/addKey?pubkey=x&pt=secret-token"))
        let text = PIATunnelDiagnostics.describe(NWHttpConnectionError.badURL(url))
        #expect(!text.contains("secret-token"))
    }

    @Test("wrapped errors are unwrapped, including the NSError underlying chain")
    func nestedErrors() {
        let underlying = NSError(domain: "Inner", code: 2)
        let error = NSError(
            domain: "Outer", code: 7,
            userInfo: [NSLocalizedDescriptionKey: "boom", NSUnderlyingErrorKey: underlying]
        )
        let text = PIATunnelDiagnostics.describe(PacketTunnelError.connectFailed(underlyingError: error))
        #expect(text.hasPrefix("connectFailed(Outer 7: boom ← Inner 2"))
    }

    @Test("failure reasons categorise timeouts and key-exchange errors")
    func failureReasons() {
        #expect(PIATunnelDiagnostics.failureReason(for: PacketTunnelError.connectionTimeout) == "timeout")
        #expect(PIATunnelDiagnostics.failureReason(for: CancellationError()) == "cancelled")
        #expect(
            PIATunnelDiagnostics.failureReason(
                for: PacketTunnelError.authenticationFailed(underlyingError: NWHttpConnectionResponseError.noResponse)
            ) == "key exchange"
        )
        #expect(PIATunnelDiagnostics.failureReason(for: PacketTunnelError.authenticationFailed(underlyingError: nil)) == "authentication")
    }

    @Test("redact strips raw and percent-encoded secrets")
    func redact() {
        let token = "a+b/c"
        let text = PIATunnelDiagnostics.redact("pt=a%2Bb%2Fc raw=a+b/c", secrets: [token])
        #expect(text == "pt=<redacted> raw=<redacted>")
    }

    @Test("payload sorts keys and redacts secrets")
    func payload() {
        let body = Data(#"{"status":"ERROR","message":"bad token tok123"}"#.utf8)
        let text = PIATunnelDiagnostics.payload(body, redacting: ["tok123"])
        #expect(text == "message=bad token <redacted>, status=ERROR")
    }

    @Test("payload reports non-JSON bodies by size")
    func payloadNotJSON() {
        #expect(PIATunnelDiagnostics.payload(Data("nope".utf8), redacting: []) == "4 byte(s), body is not a JSON object")
    }

    @Test("TLS failures are hinted as pinning failures")
    func tlsHint() {
        let error = NWHttpConnectionError.connection(.tls(errSSLBadCert))
        #expect(PIAWireguardAuthenticator.failureHint(for: error, elapsedMs: 50) == "TLS pinning failure")
        #expect(PIAWireguardAuthenticator.failureHint(for: NWHttpConnectionResponseError.noResponse, elapsedMs: 10_000) == "likely timeout")
    }
}

@Suite("Connection attempt logging")
struct PIALoggingConnectionControllerTests {

    @Test("a successful attempt forwards to the base and logs the endpoint")
    func success() async throws {
        let base = StubController()
        let logger = CapturingLogger()
        let controller = PIALoggingConnectionController(base, label: "WireGuard", logger: logger)

        try await controller.connect(configuration: StubConfiguration())

        #expect(base.connectCalls == 1)
        #expect(controller.getConnectedEndpointDetails() == StubConfiguration.endpoint)
        let lines = logger.lines
        #expect(lines.contains { $0.contains("WireGuard attempt #1 → WireGuard 1.2.3.4:1337") })
        #expect(lines.contains { $0.contains("WireGuard attempt #1 connected in") })
    }

    @Test("a failed attempt rethrows and logs the reason")
    func failure() async {
        let base = StubController()
        base.connectError = PacketTunnelError.connectionTimeout
        let logger = CapturingLogger()
        let controller = PIALoggingConnectionController(base, label: "OpenVPN", logger: logger)

        await #expect(throws: PacketTunnelError.connectionTimeout) {
            try await controller.connect(configuration: StubConfiguration())
        }
        #expect(logger.lines.contains { $0.contains("OpenVPN attempt #1 failed after") && $0.contains("reason: timeout") })
    }
}

private struct StubConfiguration: VpnConfiguration {
    static let endpoint = PacketTunnelConnectedEndpoint(host: "1.2.3.4", port: 1337, protocolDescription: "WireGuard")

    var vpnProtocolName: String { "wireguard" }
    var connectedEndpointSnapshot: PacketTunnelConnectedEndpoint? { Self.endpoint }
    var endpointsCount: Int { 1 }
}

private final class StubController: ConnectionController, @unchecked Sendable {
    var attemptReporter: (any ConnectionAttemptReporting)?
    var connectError: Error?
    var connectCalls = 0
    private var connected: PacketTunnelConnectedEndpoint?

    func connect(configuration: StubConfiguration) async throws {
        connectCalls += 1
        if let connectError { throw connectError }
        connected = configuration.connectedEndpointSnapshot
    }

    func runVPN() async -> (any Error)? { nil }

    func stop() async {}

    func getConnectedEndpointDetails() -> PacketTunnelConnectedEndpoint? { connected }
}

private final class CapturingLogger: PacketTunnelLogger, @unchecked Sendable {
    private let lock = NSLock()
    private var captured: [String] = []

    var lines: [String] { lock.withLock { captured } }

    func trace(_ message: @autoclosure () -> String) { append(message()) }
    func debug(_ message: @autoclosure () -> String) { append(message()) }
    func info(_ message: @autoclosure () -> String) { append(message()) }
    func warning(_ message: @autoclosure () -> String) { append(message()) }
    func error(_ message: @autoclosure () -> String) { append(message()) }

    private func append(_ line: String) {
        lock.withLock { captured.append(line) }
    }
}
