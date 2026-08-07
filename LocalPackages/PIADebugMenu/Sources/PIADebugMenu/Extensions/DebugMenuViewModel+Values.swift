import Foundation
@preconcurrency import PIALibrary

import struct PIABase.JWS

@available(iOS 16, tvOS 17, *)
extension DebugMenuViewModel {
    var appVersion: String {
        Macros.versionFullString() ?? "—"
    }

    var environment: String {
        Client.environment.rawValue
    }

    var baseUrl: String {
        Macros.baseUrl() ?? "—"
    }

    var accountInfo: AccountInfo? {
        Client.providers.accountProvider.currentUser?.info
    }

    var username: String {
        accountInfo?.username ?? "—"
    }

    var plan: String {
        accountInfo?.plan.rawValue ?? "—"
    }

    var productId: String {
        accountInfo?.productId ?? "—"
    }

    var isExpired: String {
        accountInfo?.isExpired.string ?? "—"
    }

    var isRenewable: String {
        accountInfo?.isRenewable.string ?? "—"
    }

    var isRecurring: String {
        accountInfo?.isRecurring.string ?? "—"
    }

    var expirationFormatted: String {
        guard let date = accountInfo?.expirationDate else { return "—" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var transactionJWS: JWS? {
        entitlementJWS
    }

    var vpnStatus: String {
        vpnConnection.status
    }

    var connectedVia: String {
        vpnConnection.connectedVia
    }

    var vpnProtocolName: String {
        switch Client.preferences.vpnType {
        case "PIAWG": return "WireGuard"
        case "PIA": return "OpenVPN"
        case "IPSec", "IKEv2": return "IKEv2"
        default: return Client.preferences.vpnType
        }
    }

    var publicIP: String {
        Client.daemons.publicIP ?? "---"
    }

    var vpnIP: String {
        Client.daemons.vpnIP ?? "---"
    }

    var logs: String {
        PIALogHandler.logStorage.getAllLogs(includeDebug: true)
    }

    /// Both log sections show only the tail of the snapshot — the full content is still one tap
    /// away via Export. Unbounded 1000-line monospaced `Text` inside a scrolling `List` is expensive
    /// to lay out on every re-render and was a source of scroll jank.
    static let previewLineCount = 25

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
            .prefix(previewLineCount)
            .joined(separator: "\n")
    }

    func buildExportContent() -> String {
        var lines: [String] = []
        lines.append("=== App Info ===")
        lines.append("Version: \(appVersion)")
        lines.append("Environment: \(environment)")
        lines.append("")
        lines.append("=== VPN ===")
        lines.append("Protocol: \(vpnProtocolName)")
        lines.append("")
        lines.append("=== Account ===")
        lines.append("Username: \(username)")
        lines.append("Plan: \(plan)")
        lines.append("Product ID: \(productId)")
        lines.append("Expiration Date: \(expirationFormatted)")
        lines.append("Is Expired: \(isExpired)")
        lines.append("Is Renewable: \(isRenewable)")
        lines.append("Is Recurring: \(isRecurring)")
        lines.append("")
        lines.append("=== Transaction (JWS) ===")
        lines.append(transactionJWS?.value ?? "Not available")
        lines.append("")
        lines.append("=== App Logs ===")
        lines.append(logs)
        lines.append("")
        lines.append("=== Tunnel Log ===")
        lines.append(tunnelLogSnapshot.isEmpty ? "No tunnel log" : tunnelLogSnapshot)
        return lines.joined(separator: "\n")
    }
}
