import Foundation
import KapeVPN_OpenVPN
import KapeVPN_PacketTunnel
import PIALibrary

extension PIAEndpointRepository {
    static let openVPNPortUDP: UInt16 = 8080
    static let openVPNPortTCP: UInt16 = 443

    /// Builds OpenVPN configurations honoring the user's saved transport/port (the explicit
    /// `.openVPN` selection). `.automatic` transport offers both UDP and TCP at their default ports
    /// (UDP first, then TCP via the SDK's demand-driven failover). Explicit `.udp`/`.tcp` use the
    /// user's selected port, falling back to the transport default when the port is automatic (0).
    func generateOpenVPNConfigurations(server: Server, state: PIATunnelSharedState.State) -> [any VpnConfiguration] {
        let transport = state.openVPN.transport
        let userPort = state.openVPN.port

        let udpPort: UInt16
        let tcpPort: UInt16
        if transport == .automatic {
            udpPort = Self.openVPNPortUDP
            tcpPort = Self.openVPNPortTCP
        } else {
            udpPort = userPort != 0 ? userPort : Self.openVPNPortUDP
            tcpPort = userPort != 0 ? userPort : Self.openVPNPortTCP
        }

        var configurations: [any VpnConfiguration] = []
        if transport == .udp || transport == .automatic {
            configurations += openVPNConfigurations(for: server, transport: .udp, port: udpPort, state: state)
        }
        if transport == .tcp || transport == .automatic {
            configurations += openVPNConfigurations(for: server, transport: .tcp, port: tcpPort, state: state)
        }
        return configurations
    }

    /// Builds OpenVPN configurations for exactly one transport at a fixed port. `transport` must be
    /// `.udp` or `.tcp`. The automatic pecking order calls this directly to dictate transport + port
    /// (UDP 8080, TCP 443) and crypto (passing `crypto: .default`, i.e. AES-128-GCM per spec);
    /// `generateOpenVPNConfigurations` passes `crypto: nil` to honor the user's persisted crypto
    /// (`state.openVPN.ovpnConfig`).
    func openVPNConfigurations(
        for server: Server,
        transport: OpenVPNTransport,
        port: UInt16,
        state: PIATunnelSharedState.State,
        crypto: AppConstants.OpenVPNCrypto? = nil
    ) -> [any VpnConfiguration] {
        guard !state.openVPN.caCertificate.isEmpty else {
            logger.error("OpenVPN CA certificate not set in shared state — returning no configurations")
            return []
        }

        let addresses = (transport == .udp ? server.openVPNAddressesForUDP : server.openVPNAddressesForTCP) ?? []
        guard !addresses.isEmpty else {
            logger.error("No OpenVPN \(transport.rawValue) addresses found for \(server.identifier) — returning no configurations")
            return []
        }

        return addresses.map { address in
            let usesPIAPatches = !address.van
            logger.debug("Built OpenVPN \(transport.rawValue) endpoint \(address.ip):\(port) (cn: \(address.cn), piaPatches: \(usesPIAPatches))")

            return OpenVPNConfiguration(
                host: address.ip,
                port: port,
                transport: transport,
                ovpnConfiguration: crypto?.ovpnConfig ?? state.openVPN.ovpnConfig,
                ovpnConfigTemplate: nil,
                xorValue: nil,
                usesPIAPatches: usesPIAPatches,
                mtu: state.openVPN.mtu,
                certDn: address.cn,
                username: state.openVPN.username,
                password: state.openVPN.password,
                caCertificate: state.openVPN.caCertificate,
                clientCertificate: "",
                clientKey: "",
                tlsAuthKey: "",
                appGroupIdentifier: AppConstants.appGroup,
                dnsServers: state.openVPN.dnsServers
            )
        }
    }
}
