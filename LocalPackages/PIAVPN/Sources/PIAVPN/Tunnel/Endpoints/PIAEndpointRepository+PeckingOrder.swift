import Foundation
import KapeVPN_OpenVPN
import KapeVPN_PacketTunnel
import PIALibrary

extension PIAEndpointRepository {
    /// One step of the automatic-protocol pecking order: a protocol/transport tried against a fixed
    /// number of distinct endpoints before falling through to the next step.
    struct PeckingStep {
        enum Kind {
            case wireGuard(amnezia: Bool)
            case openVPN(OpenVPNTransport)  // .udp or .tcp
        }

        let kind: Kind
        let port: UInt16
        let attempts: Int
    }

    static let normalPeckingOrder: [PeckingStep] = [
        PeckingStep(kind: .wireGuard(amnezia: false), port: wireGuardPort, attempts: 3),
        PeckingStep(kind: .openVPN(.udp), port: openVPNPortUDP, attempts: 2),
        PeckingStep(kind: .openVPN(.tcp), port: openVPNPortTCP, attempts: 3)
    ]

    static let censorshipPeckingOrder: [PeckingStep] = [
        PeckingStep(kind: .wireGuard(amnezia: true), port: wireGuardPort, attempts: 3),
        PeckingStep(kind: .wireGuard(amnezia: false), port: wireGuardPort, attempts: 3),
        PeckingStep(kind: .openVPN(.tcp), port: openVPNPortTCP, attempts: 2),
        PeckingStep(kind: .openVPN(.udp), port: openVPNPortUDP, attempts: 2)
    ]

    /// Builds the automatic-mode batch by walking a pecking order across the eligible servers, each
    /// step contributing up to `attempts` distinct endpoints. Defaults to the Normal-countries order.
    func automaticConfigurations(
        servers: [Server],
        state: PIATunnelSharedState.State,
        order: [PeckingStep] = PIAEndpointRepository.normalPeckingOrder
    ) -> [any VpnConfiguration] {
        var batch: [any VpnConfiguration] = []
        for step in order {
            let endpoints: [any VpnConfiguration]
            switch step.kind {
            case .wireGuard(let amnezia):
                endpoints = servers.flatMap { server -> [any VpnConfiguration] in
                    let obfuscation = amnezia ? amneziaObfuscation(for: server, state: state) : WireguardObfuscation.none
                    guard let obfuscation else {
                        return []
                    }
                    return generateWireGuardConfigurations(
                        server: server,
                        state: state,
                        obfuscation: obfuscation
                    )
                }

            case .openVPN(let transport):
                endpoints = servers.flatMap {
                    openVPNConfigurations(
                        for: $0,
                        transport: transport,
                        port: step.port,
                        state: state,
                        crypto: .default
                    )
                }
            }
            batch.append(contentsOf: endpoints.prefix(step.attempts))
        }
        logger.info("Automatic pecking order: \(batch.count) endpoint(s) across \(servers.count) server(s)")
        return batch
    }

    /// Resolves the AmneziaWG obfuscation for a censorship WireGuard step. Returns `nil` for now.
    private func amneziaObfuscation(for server: Server, state: PIATunnelSharedState.State) -> WireguardObfuscation? {
        logger.info("AmneziaWG parameters not available for \(server.identifier) yet — skipping amnezia step")
        return nil
    }
}
