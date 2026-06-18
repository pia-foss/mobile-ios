import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

extension PIAEndpointRepository {
    static let wireGuardPort: UInt16 = 1337

    func generateWireGuardConfigurations(state: PIATunnelSharedState.State) -> [any VpnConfiguration] {
        logger.info("Generating WireGuard configurations")

        guard let server = state.selectedServer else {
            logger.error("No server found in shared state — returning no configurations")
            return []
        }

        guard let addresses = server.wireGuardAddressesForUDP, !addresses.isEmpty else {
            logger.error("No WireGuard UDP addresses found for \(server.identifier) — returning no configurations")
            return []
        }
        logger.info("Found server \(server.name) with \(addresses.count) WireGuard UDP address(es)")

        let configurations: [any VpnConfiguration] = addresses.compactMap { address in
            let ip = IpAddress.v4(ipV4: address.ip)
            let endpoint = WireguardEndpointConfiguration(
                ip: ip,
                port: Self.wireGuardPort,
                authIp: ip,
                authPort: Self.wireGuardPort,
                certDn: address.cn,
                obfuscation: .none
            )
            logger.debug("Built WireGuard endpoint \(address.ip):\(Self.wireGuardPort) (cn: \(address.cn))")
            return KapeWireGuardConfig(
                endpointConfiguration: endpoint,
                host: address.ip,
                port: Self.wireGuardPort,
                obfuscation: .none
            )
        }

        logger.info("Generated \(configurations.count) WireGuard configuration(s)")
        return configurations
    }
}
