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

    /// Stands in for the real AmneziaWG parameters, which only exist once the AWG server has answered
    /// the key exchange — `PIAWireguardAuthenticator` overwrites this with the values it receives.
    static let amneziaPlaceholder: WireguardObfuscation = .amnezia(
        s1: 0, s2: 0, jc: 0, jmin: 0, jmax: 0, h1: 0, h2: 0, h3: 0, h4: 0)

    static let normalPeckingOrder: [PeckingStep] = [
        PeckingStep(kind: .wireGuard(amnezia: false), port: wireGuardPort, attempts: 3),
        PeckingStep(kind: .openVPN(.udp), port: openVPNPortUDP, attempts: 2),
        PeckingStep(kind: .openVPN(.tcp), port: openVPNPortTCP, attempts: 3)
    ]

    static let censorshipPeckingOrder: [PeckingStep] = [
        PeckingStep(kind: .wireGuard(amnezia: true), port: amneziaPort, attempts: 3),
        PeckingStep(kind: .wireGuard(amnezia: false), port: wireGuardPort, attempts: 3),
        PeckingStep(kind: .openVPN(.tcp), port: openVPNPortTCP, attempts: 2),
        PeckingStep(kind: .openVPN(.udp), port: openVPNPortUDP, attempts: 2)
    ]

    /// Countries whose networks censor plain VPN protocols, so AmneziaWG is tried first. ISO
    /// `country_code2` values, matching what `/api/geo` returns.
    static let censoredCountryCodes: Set<String> = ["CN", "IR", "RU"]

    /// Picks the pecking order from the user's own country, resolved by the app while disconnected
    /// (`ConnectivityDaemon`) and carried in shared state. Unknown country keeps the normal order:
    /// AmneziaWG is served by very few regions, so guessing censorship would waste attempts.
    func peckingOrder(for state: PIATunnelSharedState.State) -> [PeckingStep] {
        guard let countryCode = state.geoCountryCode?.uppercased() else {
            logger.info("No resolved country — using the normal pecking order")
            return Self.normalPeckingOrder
        }

        let isCensored = Self.censoredCountryCodes.contains(countryCode)
        logger.info("Country \(countryCode) — using the \(isCensored ? "censorship" : "normal") pecking order")
        return isCensored ? Self.censorshipPeckingOrder : Self.normalPeckingOrder
    }

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
                endpoints = servers.flatMap { server in
                    generateWireGuardConfigurations(
                        server: server,
                        state: state,
                        obfuscation: amnezia ? Self.amneziaPlaceholder : .none,
                        port: step.port
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
}
