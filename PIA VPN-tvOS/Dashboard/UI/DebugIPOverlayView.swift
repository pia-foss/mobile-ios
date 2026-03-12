import SwiftUI
import PIALibrary

/// DEBUG ONLY — Internal debug overlay showing the current IP address on the dashboard.
///
/// Displays the VPN tunnel IP when connected, or the public IP when disconnected.
/// Visible only in Staging and TestFlight builds; never shown to end users in production.
///
/// - Note: This view must not be used outside of debug/internal build contexts.
struct DebugIPOverlayView: View {
    // Current VPN tunnel IP — only populated while the VPN is connected.
    @State private var vpnIP: String? = Client.daemons.vpnIP
    // Public IP observed when the VPN is not active.
    @State private var publicIP: String? = Client.daemons.publicIP

    var body: some View {
        Group {
            if let ip = vpnIP {
                // Show the VPN tunnel IP while connected.
                badge(label: "VPN IP", value: ip)
            } else if let ip = publicIP {
                // Fall back to the public IP when not connected.
                badge(label: "Public IP", value: ip)
            }
        }
        // React to connectivity updates so the display stays in sync with
        // connect/disconnect events without requiring a view reload.
        .onReceive(Client.daemons.ipsPublisher) { ips in
            vpnIP = ips.vpnIP
            publicIP = ips.publicIP
        }
    }

    // MARK: - Private

    private func badge(label: String, value: String) -> some View {
        Text("\(label): \(value)")
            .font(.system(size: 22, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.55))
            .cornerRadius(10)
    }
}
