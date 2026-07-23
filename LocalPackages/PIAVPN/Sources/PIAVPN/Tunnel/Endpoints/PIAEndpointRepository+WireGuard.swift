import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

extension PIAEndpointRepository {
    static let wireGuardPort: UInt16 = 1337

    func generateWireGuardConfigurations(
        server: Server,
        state: PIATunnelSharedState.State,
        obfuscation: WireguardObfuscation = .none
    ) -> [any VpnConfiguration] {
        logger.info("Generating WireGuard configurations")

        guard let addresses = server.wireGuardAddressesForUDP, !addresses.isEmpty else {
            logger.error("No WireGuard UDP addresses found for \(server.identifier) — returning no configurations")
            return []
        }
        logger.info("Found server \(server.name) with \(addresses.count) WireGuard UDP address(es)")

        let configurations: [any VpnConfiguration] = addresses.compactMap { address in
            let ip: IpAddress = address.ip.contains(":") ? .v6(ipV6: address.ip) : .v4(ipV4: address.ip)
            let endpoint = WireguardEndpointConfiguration(
                ip: ip,
                port: Self.wireGuardPort,
                authIp: ip,
                authPort: Self.wireGuardPort,
                certDn: address.cn,
                obfuscation: obfuscation
            )
            logger.debug("Built WireGuard endpoint \(address.ip):\(Self.wireGuardPort) (cn: \(address.cn))")
            return KapeWireGuardConfig(
                endpointConfiguration: endpoint,
                host: address.ip,
                port: Self.wireGuardPort,
                obfuscation: obfuscation,
                mtu: state.wireGuard.mtu
            )
        }

        logger.info("Generated \(configurations.count) WireGuard configuration(s)")
        return configurations
    }
}
