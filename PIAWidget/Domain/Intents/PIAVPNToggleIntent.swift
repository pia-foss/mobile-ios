import AppIntents
import PIALibrary

@available(iOS 16.0, *)
struct PIAVPNToggleIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle VPN Connection"
    static var isDiscoverable: Bool = false
    static var openAppWhenRun: Bool = true

    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .foreground }

    func perform() async throws -> some IntentResult {
        if Client.providers.vpnProvider.isVPNConnected {
            Client.providers.vpnProvider.disconnect(nil)
        } else {
            Client.providers.vpnProvider.connect(nil)
        }
        return .result()
    }
}
