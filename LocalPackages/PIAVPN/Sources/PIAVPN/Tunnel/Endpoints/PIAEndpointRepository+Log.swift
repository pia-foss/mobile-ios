import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

/// Pretty-printed logging of the connection settings the tunnel is about to attempt, once per
/// connection rather than the per-endpoint `logger.debug` calls in `+OpenVPN`/`+WireGuard` (which
/// repeat per candidate IP and omit cipher/auth/MTU/DNS).
extension PIAEndpointRepository {
    /// The shared state the tunnel read, logged before anything is derived from it. Unlike
    /// `logConnectionSummary` this fires for `.automatic` too, which would otherwise log no inputs.
    func logStateSummary(_ state: PIATunnelSharedState.State) {
        let target: String
        if let dip = state.selectedDipServer {
            target = "dedicated IP (\(dip.name))"
        } else if let locationId = state.selectedLocationId {
            target = "region \(locationId)"
        } else {
            target = "automatic (no selection)"
        }

        logger.info(
            "Shared state: target: \(target), servers: \(state.servers.count), "
                + "latencies: \(state.latencyByServerId.count), status: \(state.tunnelStatus?.rawValue ?? "none")"
        )
    }

    /// Which server the batch will be built from. `State.selectedServer(in:)` silently substitutes the
    /// fastest available one when `selectedLocationId` is absent from the list, so that swap is warned
    /// about rather than left to be inferred.
    func logResolvedServer(_ server: Server, state: PIATunnelSharedState.State) {
        let kind = server.dipToken != nil ? "dedicated IP" : "region"
        logger.info("Resolved \(kind) server: \(server.name) (\(server.identifier))")

        if let requested = state.selectedLocationId, server.identifier != requested, server.dipToken == nil {
            logger.warning(
                "Requested region \(requested) is not in the current server list — "
                    + "fell back to \(server.name) (\(server.identifier))"
            )
        }
    }

    func logConnectionSummary(_ state: PIATunnelSharedState.State) {
        let lines: [String]
        switch state.selectedProtocol {
        case .openVPN:
            lines = ["protocol: OpenVPN"] + openVPNSummaryLines(state.openVPN)
        case .wireGuard:
            lines = ["protocol: WireGuard"] + wireGuardSummaryLines(state.wireGuard)
        case .automatic:
            return
        }
        logger.info("Connecting with:\n" + lines.map { "  \($0)" }.joined(separator: "\n"))
    }

    func logPeckingOrderSummary(_ order: [PIAEndpointRepository.PeckingStep], state: PIATunnelSharedState.State) {
        let steps = order.enumerated().map { index, step in
            "\(index + 1). \(peckingStepSummary(step, state: state))"
        }
        logger.info("Connecting — protocol: Automatic, pecking order:\n" + steps.map { "  \($0)" }.joined(separator: "\n"))
    }

    private func peckingStepSummary(_ step: PIAEndpointRepository.PeckingStep, state: PIATunnelSharedState.State) -> String {
        switch step.kind {
        case .wireGuard(let amnezia):
            let isSmallPackets = state.wireGuard.mtu == UInt16(AppConstants.WireGuardPacketSize.defaultPacketSize)
            return "WireGuard\(amnezia ? " (Amnezia obfuscation)" : "") — port: \(step.port), attempts: \(step.attempts), "
                + "mtu: \(state.wireGuard.mtu) (small packets: \(isSmallPackets ? "on" : "off")), dns: \(dnsSummary(state.wireGuard.dnsServers))"
        case .openVPN(let transport):
            let isSmallPackets = state.openVPN.mtu == UInt16(AppConstants.OpenVPNPacketSize.smallPacketSize)
            let crypto = AppConstants.OpenVPNCrypto.default.ovpnConfig.split(separator: "\n").joined(separator: ", ")
            return "OpenVPN \(transport.rawValue) — port: \(step.port), attempts: \(step.attempts), \(crypto), "
                + "mtu: \(state.openVPN.mtu) (small packets: \(isSmallPackets ? "on" : "off")), dns: \(dnsSummary(state.openVPN.dnsServers))"
        }
    }

    private func openVPNSummaryLines(_ settings: PIATunnelSharedState.OpenVPNSettings) -> [String] {
        let isSmallPackets = settings.mtu == UInt16(AppConstants.OpenVPNPacketSize.smallPacketSize)
        // Port 0 means "automatic"; show what `+OpenVPN` resolves it to so the summary matches the
        // endpoints actually built.
        let port: String
        if settings.port != 0 {
            port = "\(settings.port)"
        } else {
            switch settings.transport {
            case .udp: port = "automatic (\(PIAEndpointRepository.openVPNPortUDP))"
            case .tcp: port = "automatic (\(PIAEndpointRepository.openVPNPortTCP))"
            default:
                port = "automatic (udp \(PIAEndpointRepository.openVPNPortUDP), tcp \(PIAEndpointRepository.openVPNPortTCP))"
            }
        }
        var lines = ["transport: \(settings.transport.rawValue), port: \(port)"]
        // `ovpnConfig` is exactly "cipher <X>\nauth <Y>" (see `AppConstants.OpenVPNCrypto.ovpnConfig`).
        lines += settings.ovpnConfig.split(separator: "\n").map(String.init)
        lines.append("mtu: \(settings.mtu) (small packets: \(isSmallPackets ? "on" : "off"))")
        lines.append("dns: \(dnsSummary(settings.dnsServers))")
        return lines
    }

    private func wireGuardSummaryLines(_ settings: PIATunnelSharedState.WireGuardSettings) -> [String] {
        let isSmallPackets = settings.mtu == UInt16(AppConstants.WireGuardPacketSize.defaultPacketSize)
        return [
            "mtu: \(settings.mtu) (small packets: \(isSmallPackets ? "on" : "off"))",
            "dns: \(dnsSummary(settings.dnsServers))"
        ]
    }

    private func dnsSummary(_ dnsServers: [String]) -> String {
        dnsServers.isEmpty ? "server-provided" : dnsServers.joined(separator: ", ")
    }
}
