import Foundation
@preconcurrency import PIALibrary

@available(iOS 16, *)
extension DebugMenuView {
    var appVersion: String {
        Macros.versionFullString() ?? "—"
    }

    nonisolated var environment: String {
        Client.environment.rawValue
    }

    var baseUrl: String {
        Macros.baseUrl() ?? "—"
    }

    nonisolated var accountInfo: AccountInfo? {
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

    nonisolated var receiptBase64: String? {
        Client.store.paymentReceipt?.base64EncodedString()
    }

    var logs: String {
        PIALogHandler.logStorage.getAllLogs()
    }

    func buildExportContent() -> String {
        var lines: [String] = []
        lines.append("=== App Info ===")
        lines.append("Version: \(appVersion)")
        lines.append("Environment: \(environment)")
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
        lines.append("=== Payment Receipt ===")
        lines.append(receiptBase64 ?? "Not available")
        lines.append("")
        lines.append("=== Logs ===")
        lines.append(logs)
        return lines.joined(separator: "\n")
    }
}
