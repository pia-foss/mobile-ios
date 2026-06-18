import KapeVPN_PacketTunnel
import PIALibrary

final class PIAEndpointRepository: VpnConfigurationGenerator, Sendable {
    let logger = PIATunnelLogger(label: "PIAEndpointRepository")

    func generateConfigurations() async -> [any VpnConfiguration] {
        let state = PIATunnelSharedState.read(appGroup: AppConstants.appGroup)

        switch state.selectedProtocol {
        case .wireGuard:
            return generateWireGuardConfigurations(state: state)
        case .openVPN:
            return generateOpenVPNConfigurations(state: state)
        }
    }
}
