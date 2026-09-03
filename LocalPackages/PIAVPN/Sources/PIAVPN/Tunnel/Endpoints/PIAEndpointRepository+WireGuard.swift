import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

extension PIAEndpointRepository {
    static let wireGuardPort: UInt16 = 1337
    static let amneziaPort: UInt16 = 1338

    func generateWireGuardConfigurations(
        server: Server,
        state: PIATunnelSharedState.State,
        obfuscation: WireguardObfuscation = .none,
        port: UInt16 = PIAEndpointRepository.wireGuardPort
    ) -> [any VpnConfiguration] {
        let isAmnezia = if case .amnezia = obfuscation {
            true
        } else {
            false
        }

        let label = isAmnezia ? "AmneziaWG" : "WireGuard"
        let addresses = isAmnezia ? server.amneziaAddressesForUDP : server.wireGuardAddressesForUDP

        // Called once per eligible server, so per-server outcomes stay at `debug` — a server without
        // WireGuard addresses is normal during a fan-out, not an error.
        guard let addresses, !addresses.isEmpty else {
            logger.debug("No \(label) UDP addresses for \(server.identifier) — contributing no configurations")
            return []
        }

        let configurations: [any VpnConfiguration] = addresses.compactMap { address in
            let ip = IpAddress(parsing: address.ip)
            // The server list carries a port for AmneziaWG only; everything else uses the step's.
            let endpointPort = address.port ?? port
            let endpoint = WireguardEndpointConfiguration(
                ip: ip,
                port: endpointPort,
                authIp: ip,
                authPort: endpointPort,
                certDn: address.cn,
                obfuscation: obfuscation
            )
            logger.debug("Built \(label) endpoint \(address.ip):\(endpointPort) (cn: \(address.cn))")
            return KapeWireGuardConfig(
                endpointConfiguration: endpoint,
                host: address.ip,
                port: endpointPort,
                obfuscation: obfuscation,
                mtu: state.wireGuard.mtu
            )
        }

        logger.debug("Built \(configurations.count) \(label) endpoint(s) for \(server.name)")
        return configurations
    }
}
