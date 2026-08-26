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
        // Called once per eligible server, so per-server outcomes stay at `debug` — a server without
        // WireGuard addresses is normal during a fan-out, not an error.
        guard let addresses = server.wireGuardAddressesForUDP, !addresses.isEmpty else {
            logger.debug("No WireGuard UDP addresses for \(server.identifier) — contributing no configurations")
            return []
        }

        let configurations: [any VpnConfiguration] = addresses.compactMap { address in
            let ip = IpAddress(parsing: address.ip)
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

        logger.debug("Built \(configurations.count) WireGuard endpoint(s) for \(server.name)")
        return configurations
    }
}
