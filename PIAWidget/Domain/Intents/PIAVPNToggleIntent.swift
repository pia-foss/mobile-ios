import AppIntents
import PIALibrary
import PIALocalizations

@available(iOS 16.0, *)
private let log = PIALogger.logger(for: PIAVPNToggleIntent.self)

@available(iOS 16.0, *)
struct PIAVPNToggleIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle VPN Connection"
    static var isDiscoverable: Bool = false
    static var openAppWhenRun: Bool = true

    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .foreground }

    func perform() async throws -> some IntentResult {
        let error: Error? = await withCheckedContinuation { continuation in
            let callback = { error in
                continuation.resume(returning: error)
            }
            // Runs in the main thread after some delay, allowing the app to fully open from a cold start if needed.
            Macros.dispatch(after: .milliseconds(200)) {
                if Client.providers.vpnProvider.isVPNConnected {
                    Client.providers.vpnProvider.disconnect(callback)
                } else {
                    Client.providers.vpnProvider.connect(callback)
                }
            }
        }

        if let error {
            log.error("Failed to toggle VPN: \(error)")
        }
        return .result()
    }
}
