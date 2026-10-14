import Foundation

/// The connection state as observed by the caller. Both values are supplied rather than read from
/// `Client.daemons`, because only the caller can see tunnels installed by other apps.
public struct VPNConnectionInformation: Sendable {
    public let status: String
    public let connectedVia: String

    public init(status: String, connectedVia: String) {
        self.status = status
        self.connectedVia = connectedVia
    }
}

extension Client {
    /// Submits a CSI debug report directly, bypassing the VPN provider.
    /// Use this instead of `providers.vpnProvider.submitDebugReport` when a VPN
    /// profile may not be configured (e.g. simulator, mock VPN builds).
    /// Includes debug logs only if the user has enabled debug logging, and the tunnel log (see
    /// `includeTunnelLog` below). IPs are always redacted.
    public static func submitDebugReport() async throws -> String {
        try await PIAWebServices().submitDebugReport()
    }

    /// Submits a CSI debug report with explicit control over log verbosity and IP redaction.
    /// Use this overload when the caller needs to override the defaults, e.g. internal debug tools
    /// that always include debug logs and don't need IP redaction.
    /// `includeTunnelLog` adds a `tunnel.log` section fetched from the Network Extension, or a
    /// `last_tunnel.log` section with the log it persisted last when the tunnel is down; and
    /// `vpnConnection` a `vpn_status` section. Both are omitted by default here; the user-facing
    /// `submitDebugReport()` above opts into the tunnel log.
    public static func submitDebugReport(
        includeDebug: Bool,
        redactIPs: Bool,
        includeTunnelLog: Bool = false,
        vpnConnection: VPNConnectionInformation? = nil
    ) async throws -> String {
        try await PIAWebServices().submitDebugReport(
            includeDebug: includeDebug,
            redactIPs: redactIPs,
            includeTunnelLog: includeTunnelLog,
            vpnConnection: vpnConnection
        )
    }

    /// Builds the CSI debug report that `submitDebugReport()` would send, without submitting it, so
    /// a review screen can show exactly what is about to leave the device. Pair it with
    /// `submitDebugReport(_:)` below to guarantee the submitted content matches what was shown.
    public static func buildDebugReport(
        includeDebug: Bool,
        redactIPs: Bool,
        includeTunnelLog: Bool = false,
        vpnConnection: VPNConnectionInformation? = nil
    ) async -> DebugReport {
        await PIAWebServices().buildDebugReport(
            includeDebug: includeDebug,
            redactIPs: redactIPs,
            includeTunnelLog: includeTunnelLog,
            vpnConnection: vpnConnection
        )
    }

    /// Submits a report that was previously built, e.g. after the user reviewed it.
    public static func submitDebugReport(_ report: DebugReport) async throws -> String {
        try await PIAWebServices().submit(report: report)
    }
}
