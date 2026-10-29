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

        let listAge = state.serversFetchedAt.map { "\(Int(Date().timeIntervalSince($0)))s" } ?? "never fetched"
        logger.info(
            "Shared state: target: \(target), protocol: \(state.selectedProtocol.rawValue), "
                + "country: \(state.geoCountryCode ?? "unknown"), servers: \(state.servers.count) (age: \(listAge)), "
                + "latencies: \(state.latencyByServerId.count), status: \(state.tunnelStatus?.rawValue ?? "none")"
        )
    }

    /// Which server the batch will be built from. `State.selectedServer(in:)` silently substitutes the
    /// fastest available one when `selectedLocationId` is absent from the list, so that swap is warned
    /// about rather than left to be inferred.
    func logResolvedServer(_ server: Server, state: PIATunnelSharedState.State) {
        let kind = server.dipToken != nil ? "dedicated IP" : "region"
        let latency = state.latencyByServerId[server.identifier].map { "\($0)ms" } ?? "unmeasured"
        logger.info(
            "Resolved \(kind) server: \(server.name) (\(server.identifier)), offline: \(server.offline), "
                + "latency: \(latency), addresses: \(addressInventory(server))"
        )
        logger.debug("Addresses for \(server.identifier):\n" + addressLines(server).map { "  \($0)" }.joined(separator: "\n"))
        warnAboutMissingAddresses(server, state: state)

        if let requested = state.selectedLocationId, server.identifier != requested, server.dipToken == nil {
            logger.warning(
                "Requested region \(requested) is not in the current server list — "
                    + "fell back to \(server.name) (\(server.identifier))"
            )
        }
    }

    private func addressInventory(_ server: Server) -> String {
        "wg: \(server.wireGuardAddressesForUDP?.count ?? 0), ovpn-udp: \(server.openVPNAddressesForUDP?.count ?? 0), "
            + "ovpn-tcp: \(server.openVPNAddressesForTCP?.count ?? 0), awg: \(server.amneziaAddressesForUDP?.count ?? 0)"
    }

    private func addressLines(_ server: Server) -> [String] {
        let groups: [(String, [Server.ServerAddressIP]?)] = [
            ("wg", server.wireGuardAddressesForUDP),
            ("ovpn-udp", server.openVPNAddressesForUDP),
            ("ovpn-tcp", server.openVPNAddressesForTCP),
            ("awg", server.amneziaAddressesForUDP)
        ]
        return groups.map { name, addresses in
            let list = (addresses ?? []).map { address in
                "\(address.ip)\(address.port.map { ":\($0)" } ?? "") (cn: \(address.cn))"
            }
            return "\(name): \(list.isEmpty ? "none" : list.joined(separator: ", "))"
        }
    }

    /// A region lacking addresses for what we are about to try is the usual "can't connect to X" cause.
    private func warnAboutMissingAddresses(_ server: Server, state: PIATunnelSharedState.State) {
        let isMissing: [String: Bool] = [
            "wg": server.wireGuardAddressesForUDP?.isEmpty ?? true,
            "ovpn-udp": server.openVPNAddressesForUDP?.isEmpty ?? true,
            "ovpn-tcp": server.openVPNAddressesForTCP?.isEmpty ?? true,
            "awg": server.amneziaAddressesForUDP?.isEmpty ?? true
        ]

        let needed: [String]
        switch state.selectedProtocol {
        case .wireGuard:
            needed = ["wg"]
        case .openVPN:
            switch state.openVPN.transport {
            case .udp: needed = ["ovpn-udp"]
            case .tcp: needed = ["ovpn-tcp"]
            case .automatic: needed = ["ovpn-udp", "ovpn-tcp"]
            }
        case .automatic:
            needed = ["wg", "ovpn-udp", "ovpn-tcp", "awg"]
        }

        let missing = needed.filter { isMissing[$0] == true }
        guard !missing.isEmpty else { return }
        logger.warning(
            "\(server.name) (\(server.identifier)) has no \(missing.joined(separator: ", ")) addresses — "
                + "protocol: \(state.selectedProtocol.rawValue)\(missing.count == needed.count ? ", nothing to attempt" : "")"
        )
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
