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
        logPeckingOrderSummary(order, state: state)
        var batch: [any VpnConfiguration] = []
        for (index, step) in order.enumerated() {
            let endpoints: [any VpnConfiguration]
            switch step.kind {
            case .wireGuard(let amnezia):
                // Resolved per step, not per server, so the fan-out can't repeat the same line.
                let obfuscation: WireguardObfuscation
                if amnezia {
                    guard let resolved = amneziaObfuscation(state: state) else {
                        logger.info("Step \(index + 1)/\(order.count) (AmneziaWG): parameters not available yet — skipped")
                        continue
                    }
                    obfuscation = resolved
                } else {
                    obfuscation = .none
                }
                endpoints = servers.flatMap { server in
                    generateWireGuardConfigurations(
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

            // `prefix` discards the rest of the fan-out, so log the ratio — a step contributing
            // nothing is invisible in the batch total alone.
            let taken = endpoints.prefix(step.attempts)
            batch.append(contentsOf: taken)
            let summary =
                "Step \(index + 1)/\(order.count) (\(stepLabel(step))): "
                + "took \(taken.count) of \(endpoints.count) candidate endpoint(s), attempts: \(step.attempts)"
            if taken.isEmpty {
                logger.warning(summary + " — step contributes nothing")
            } else {
                logger.info(summary)
            }
        }
        logger.info("Automatic pecking order: \(batch.count) endpoint(s) across \(servers.count) server(s)")
        return batch
    }

    /// Short protocol/transport tag identifying a step in the per-step logs.
    private func stepLabel(_ step: PeckingStep) -> String {
        switch step.kind {
        case .wireGuard(let amnezia):
            return "WireGuard\(amnezia ? " amnezia" : "") :\(step.port)"
        case .openVPN(let transport):
            return "OpenVPN \(transport.rawValue) :\(step.port)"
        }
    }

    /// Resolves the AmneziaWG obfuscation for a censorship WireGuard step. Returns `nil` for now.
    /// Server-independent — the caller resolves it once per step and logs the outcome there.
    private func amneziaObfuscation(state: PIATunnelSharedState.State) -> WireguardObfuscation? {
        nil
    }
}
