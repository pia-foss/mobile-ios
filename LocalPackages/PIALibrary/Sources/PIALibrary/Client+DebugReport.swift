import Foundation

extension Client {
    /// Submits a CSI debug report directly, bypassing the VPN provider.
    /// Use this instead of `providers.vpnProvider.submitDebugReport` when a VPN
    /// profile may not be configured (e.g. simulator, mock VPN builds).
    public static func submitDebugReport(includePersistedData: Bool, logs: String, _ callback: LibraryCallback<String>?) {
        PIAWebServices().submitDebugReport(includePersistedData, logs, callback)
    }
}
