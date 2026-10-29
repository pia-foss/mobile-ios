import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

/// Logs each connect attempt's endpoint, duration and failure reason, which the SDK run loop omits.
final class PIALoggingConnectionController<Base: ConnectionController>: ConnectionController {
    typealias Configuration = Base.Configuration

    private struct State {
        var attempts = 0
        var connectedAt: Date?
    }

    private let base: Base
    private let label: String
    private let logger: any PacketTunnelLogger
    private let state = Mutex(State())

    init(_ base: Base, label: String, logger: any PacketTunnelLogger) {
        self.base = base
        self.label = label
        self.logger = logger
    }

    var attemptReporter: (any ConnectionAttemptReporting)? {
        get { base.attemptReporter }
        set { base.attemptReporter = newValue }
    }

    func connect(configuration: Configuration) async throws {
        let attempt = state.withLock { state in
            state.attempts += 1
            state.connectedAt = nil
            return state.attempts
        }
        let target = Self.describe(configuration)
        let start = Date()
        logger.info("\(label) attempt #\(attempt) → \(target)")

        do {
            try await base.connect(configuration: configuration)
        } catch {
            logger.error(
                "\(label) attempt #\(attempt) failed after \(PIATunnelDiagnostics.elapsedMs(since: start))ms — "
                    + "reason: \(PIATunnelDiagnostics.failureReason(for: error)), \(target), "
                    + "error: \(PIATunnelDiagnostics.describe(error))"
            )
            throw error
        }

        state.withLock { $0.connectedAt = Date() }
        logger.info("\(label) attempt #\(attempt) connected in \(PIATunnelDiagnostics.elapsedMs(since: start))ms — \(target)")
    }

    func runVPN() async -> (any Error)? {
        let error = await base.runVPN()
        let uptime = state.withLock { $0.connectedAt }.map { "\(Int(Date().timeIntervalSince($0)))s" } ?? "unknown"
        if let error {
            logger.warning(
                "\(label) tunnel ended after \(uptime) — reason: \(PIATunnelDiagnostics.failureReason(for: error)), "
                    + "error: \(PIATunnelDiagnostics.describe(error))"
            )
        } else {
            logger.info("\(label) tunnel ended cleanly after \(uptime)")
        }
        return error
    }

    func stop() async {
        logger.debug("\(label) stopping")
        await base.stop()
    }

    func getConnectedEndpointDetails() -> PacketTunnelConnectedEndpoint? {
        base.getConnectedEndpointDetails()
    }

    func currentDataUsage() async -> PacketTunnelDataUsage? {
        await base.currentDataUsage()
    }

    private static func describe(_ configuration: Configuration) -> String {
        let details = "obfuscation: \(configuration.obfuscationDescription), cipher: \(configuration.cipherDescription)"
        guard let endpoint = configuration.connectedEndpointSnapshot else {
            return "\(configuration.vpnProtocolName) (no endpoint), \(details)"
        }
        return "\(endpoint.protocolDescription) \(endpoint.host):\(endpoint.port), \(details)"
    }
}
