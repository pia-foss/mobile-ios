import Foundation
import PIALibrary

/// Read-only values the screen and the export derive from state.
extension DebugMenu.State {
    var vpnStatus: String {
        vpnConnection.status
    }

    var connectedVia: String {
        vpnConnection.connectedVia
    }

    var username: String { account?.username ?? "—" }
    var plan: String { account?.plan ?? "—" }
    var productId: String { account?.productId ?? "—" }
    var expiration: String { account?.expiration ?? "—" }
    var isExpired: String { account?.isExpired.string ?? "—" }
    var isRenewable: String { account?.isRenewable.string ?? "—" }
    var isRecurring: String { account?.isRecurring.string ?? "—" }

    /// Capped like the log sections, and for the same reason: a pinned protocol with an Automatic
    /// region yields one configuration per online server — hundreds of rows. Export is uncapped.
    var connectionConfigurationsPreview: [PIAConnectionConfiguration] {
        Array(connectionConfigurations.prefix(DebugMenu.previewLineCount))
    }

    /// `vpnProtocol` already carries the obfuscation ("WireGuard+Amnezia"), so the endpoint alone is
    /// the whole value.
    func endpoint(of configuration: PIAConnectionConfiguration) -> String {
        "\(configuration.host):\(configuration.port)"
    }

    var logPreview: String {
        logSnapshot.isEmpty ? "No logs" : Self.reversedPreview(of: logSnapshot)
    }

    var tunnelLogPreview: String {
        tunnelLogSnapshot.isEmpty ? "No tunnel log" : Self.reversedPreview(of: tunnelLogSnapshot)
    }

    private static func reversedPreview(of content: String) -> String {
        content
            .components(separatedBy: "\n")
            .reversed()
            .prefix(DebugMenu.previewLineCount)
            .joined(separator: "\n")
    }

    var exportContent: String {
        var lines: [String] = []
        lines.append("=== App Info ===")
        lines.append("Version: \(appInfo.version)")
        lines.append("Environment: \(appInfo.environment)")
        lines.append("")
        lines.append("=== VPN ===")
        lines.append("Protocol: \(liveInfo.protocolName)")
        lines.append("VPN IP (PIA's Endpoint): \(liveInfo.vpnIP)")
        lines.append("VPN IP (ipify): \(ipifyIP)")
        lines.append("")
        lines.append("=== Connection Configurations ===")
        if connectionConfigurations.isEmpty {
            lines.append("Tunnel not running")
        } else {
            lines += connectionConfigurations.map { configuration in
                "\(configuration.vpnProtocol)  \(endpoint(of: configuration))"
            }
        }
        lines.append("")
        lines.append("=== Account ===")
        lines.append("Username: \(username)")
        lines.append("Plan: \(plan)")
        lines.append("Product ID: \(productId)")
        lines.append("Expiration Date: \(expiration)")
        lines.append("Is Expired: \(isExpired)")
        lines.append("Is Renewable: \(isRenewable)")
        lines.append("Is Recurring: \(isRecurring)")
        lines.append("")
        lines.append("=== Transaction (JWS) ===")
        lines.append(transactionJWS ?? "Not available")
        lines.append("")
        lines.append("=== App Logs ===")
        lines.append(logSnapshot)
        lines.append("")
        lines.append("=== Tunnel Log ===")
        lines.append(tunnelLogSnapshot.isEmpty ? "No tunnel log" : tunnelLogSnapshot)
        return lines.joined(separator: "\n")
    }
}
