import Foundation

extension Client {
    /// Submits a CSI debug report directly, bypassing the VPN provider.
    /// Use this instead of `providers.vpnProvider.submitDebugReport` when a VPN
    /// profile may not be configured (e.g. simulator, mock VPN builds).
    /// Includes debug logs only if the user has enabled debug logging. IPs are always redacted.
    public static func submitDebugReport() async throws -> String {
        try await PIAWebServices().submitDebugReport()
    }

    /// Submits a CSI debug report with explicit control over log verbosity and IP redaction.
    /// Use this overload when the caller needs to override the defaults, e.g. internal debug tools
    /// that always include debug logs and don't need IP redaction.
    public static func submitDebugReport(includeDebug: Bool, redactIPs: Bool) async throws -> String {
        try await PIAWebServices().submitDebugReport(includeDebug: includeDebug, redactIPs: redactIPs)
    }
}
