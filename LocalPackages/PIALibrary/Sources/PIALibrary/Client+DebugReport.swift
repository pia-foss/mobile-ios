import Foundation

extension Client {
    /// Submits a CSI debug report directly, bypassing the VPN provider.
    /// Use this instead of `providers.vpnProvider.submitDebugReport` when a VPN
    /// profile may not be configured (e.g. simulator, mock VPN builds).
    public static func submitDebugReport(includePersistedData: Bool, logs: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            PIAWebServices().submitDebugReport(includePersistedData, logs) { reportId, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let reportId, !reportId.isEmpty {
                    continuation.resume(returning: reportId)
                } else {
                    continuation.resume(throwing: ClientError.malformedResponseData)
                }
            }
        }
    }
}
