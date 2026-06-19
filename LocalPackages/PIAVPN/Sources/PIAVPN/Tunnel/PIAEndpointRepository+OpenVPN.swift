import Foundation
import KapeVPN_OpenVPN
import KapeVPN_PacketTunnel
import PIALibrary

extension PIAEndpointRepository {
    static let openVPNPortUDP: UInt16 = 8080
    static let openVPNPortTCP: UInt16 = 443

    func generateOpenVPNConfigurations(state: PIATunnelSharedState.State) -> [any VpnConfiguration] {
        logger.info("Generating OpenVPN configurations")

        guard !state.openVPNCaCertificate.isEmpty else {
            logger.error("OpenVPN CA certificate not set in shared state — returning no configurations")
            return []
        }

        guard let server = state.selectedServer else {
            logger.error("No server found in shared state — returning no configurations")
            return []
        }

        let udpAddresses = server.openVPNAddressesForUDP ?? []
        let tcpAddresses = server.openVPNAddressesForTCP ?? []

        guard !udpAddresses.isEmpty || !tcpAddresses.isEmpty else {
            logger.error("No OpenVPN addresses found for \(server.identifier) — returning no configurations")
            return []
        }

        logger.info("Found server \(server.name) with \(udpAddresses.count) UDP / \(tcpAddresses.count) TCP OpenVPN address(es)")

        let udpPort = state.openVPNPort != 0 ? state.openVPNPort : Self.openVPNPortUDP
        let tcpPort = state.openVPNPort != 0 ? state.openVPNPort : Self.openVPNPortTCP

        // Honor the user's transport choice; `.automatic` offers both UDP and TCP (UDP first,
        // then TCP via the SDK's demand-driven failover).
        let transport = state.openVPNTransport
        let includeUDP = transport != .tcp
        let includeTCP = transport != .udp
        logger.info("OpenVPN transport: \(transport.rawValue) (UDP: \(includeUDP), TCP: \(includeTCP))")

        var configurations: [any VpnConfiguration] = []

        if includeUDP {
            for address in udpAddresses {
                let usesPIAPatches = !address.van
                configurations.append(makeOpenVPNConfig(ip: address.ip, cn: address.cn, transport: .udp, port: udpPort, state: state, usesPIAPatches: usesPIAPatches))
                logger.debug("Built OpenVPN UDP endpoint \(address.ip):\(udpPort) (cn: \(address.cn), piaPatches: \(usesPIAPatches))")
            }
        }

        if includeTCP {
            for address in tcpAddresses {
                let usesPIAPatches = !address.van
                configurations.append(makeOpenVPNConfig(ip: address.ip, cn: address.cn, transport: .tcp, port: tcpPort, state: state, usesPIAPatches: usesPIAPatches))
                logger.debug("Built OpenVPN TCP endpoint \(address.ip):\(tcpPort) (cn: \(address.cn), piaPatches: \(usesPIAPatches))")
            }
        }

        logger.info("Generated \(configurations.count) OpenVPN configuration(s)")
        return configurations
    }

    private func makeOpenVPNConfig(
        ip: String,
        cn: String,
        transport: OpenVPNTransport,
        port: UInt16,
        state: PIATunnelSharedState.State,
        usesPIAPatches: Bool
    ) -> OpenVPNConfiguration {
        OpenVPNConfiguration(
            host: ip,
            port: port,
            transport: transport,
            ovpnConfiguration: state.openVPNOvpnConfig,
            ovpnConfigTemplate: nil,
            xorValue: nil,
            usesPIAPatches: usesPIAPatches,
            mtu: state.openVPNMtu,
            certDn: cn,
            username: state.openVPNUsername,
            password: state.openVPNPassword,
            caCertificate: state.openVPNCaCertificate,
            clientCertificate: "",
            clientKey: "",
            tlsAuthKey: "",
            appGroupIdentifier: AppConstants.appGroup
        )
    }
}
