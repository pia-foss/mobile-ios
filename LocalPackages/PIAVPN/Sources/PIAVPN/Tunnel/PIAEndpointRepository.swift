import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

final class PIAEndpointRepository: VpnConfigurationGenerator, Sendable {
    let logger = PIATunnelLogger(label: "PIAEndpointRepository")

    func generateConfigurations() async -> [any VpnConfiguration] {
        let state = PIATunnelSharedState.read()
        let servers = await resolveServers(state: state)

        // A concrete region (or DIP) was selected: connect to that one server, as before.
        if state.selectedDipServer != nil || state.selectedLocationId != nil {
            guard let server = state.selectedServer(in: servers) else {
                logger.error("No server could be resolved — returning no configurations")
                return []
            }
            return configurations(for: server, state: state)
        }

        // "Automatic" (no selected location): fan out across every online server, fastest first, so
        // the session controller tries the lowest-latency server first and falls through the rest.
        let ordered = serversByLatency(servers, state: state)
        logger.info("Automatic (no selection): \(ordered.count) server(s), fastest first")
        return ordered.flatMap {
            configurations(for: $0, state: state)
        }
    }

    /// Builds the connection configurations for a single server, honoring the selected protocol.
    private func configurations(for server: Server, state: PIATunnelSharedState.State) -> [any VpnConfiguration] {
        switch state.selectedProtocol {
        case .wireGuard:
            return generateWireGuardConfigurations(server: server, state: state)
        case .openVPN:
            return generateOpenVPNConfigurations(server: server, state: state)
        }
    }

    /// Orders the candidate servers fastest first for the "Automatic" fan-out.
    ///
    /// Only online, non-DIP servers are eligible. Servers with a measured latency
    /// (`state.latencyByServerId`, mirrored from the app's `ServersPinger`) sort ascending and ahead
    /// of unmeasured ones, which fall to the end — so an app-less or never-pinged state still yields a
    /// non-empty, ordered list rather than nothing.
    private func serversByLatency(_ servers: [Server], state: PIATunnelSharedState.State) -> [Server] {
        let candidates = servers.filter {
            $0.dipToken == nil && !$0.offline
        }

        return candidates.sorted { lhs, rhs in
            // Unmeasured servers sort to the end (treated as the slowest possible latency).
            let lhsLatency = state.latencyByServerId[lhs.identifier] ?? .max
            let rhsLatency = state.latencyByServerId[rhs.identifier] ?? .max
            return lhsLatency < rhsLatency
        }
    }

    /// Resolves the server list to draw endpoints from, reusing the file-backed cache while it is
    /// fresh and otherwise fetching a new list and persisting it for the next connect.
    ///
    /// Dedicated IP servers are per-user and not served by the public regions list, so for a DIP
    /// target we skip the fetch and use the shared-state list as-is (the app ships just the DIP
    /// server there). Otherwise: while `serversFetchedAt` is within the TTL we reuse `state.servers`
    /// without hitting the network; once stale (or never fetched) we fetch a fresh list, write it
    /// back to shared state — so the next process, including on-demand reconnects with no app
    /// running, reuses it — and only fall back to the existing list on failure.
    private func resolveServers(state: PIATunnelSharedState.State) async -> [Server] {
        if state.selectedDipServer != nil {
            return state.servers
        }

        if let fetchedAt = state.serversFetchedAt,
            Date().timeIntervalSince(fetchedAt) < PIATunnelSharedState.serversCacheTTL,
            !state.servers.isEmpty
        {
            logger.info("Reusing cached server list (fetched \(Int(Date().timeIntervalSince(fetchedAt)))s ago)")
            return state.servers
        }

        if let fetched = await Client.downloadServerList() {
            logger.info("Fetched fresh server list — caching it in shared state")
            PIATunnelSharedState.updateServers(fetched)
            return fetched
        }

        logger.info("Falling back to the existing server list in shared state")
        return state.servers
    }
}
