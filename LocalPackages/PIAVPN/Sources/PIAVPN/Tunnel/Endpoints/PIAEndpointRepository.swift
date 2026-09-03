import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

final class PIAEndpointRepository: VpnConfigurationGenerator, Sendable {
    let logger = PIATunnelLogger(label: "PIAEndpointRepository")

    func generateConfigurations() async -> [any VpnConfiguration] {
        let state = PIATunnelSharedState.read()
        logStateSummary(state)
        logConnectionSummary(state)
        let servers = await resolveServers(state: state)

        // Resolve the eligible servers, fastest first. A concrete region (or DIP) narrows this to a
        // single server; "Automatic" (no selected location) fans out across every online server so
        // the pecking order can draw its distinct endpoints from the lowest-latency ones.
        let eligible: [Server]
        if state.selectedDipServer != nil || state.selectedLocationId != nil {
            guard let server = state.selectedServer(in: servers) else {
                logger.error("No server could be resolved — returning no configurations")
                return []
            }
            logResolvedServer(server, state: state)
            eligible = [server]
        } else {
            eligible = serversByLatency(servers, state: state)
        }

        let batch = configurations(for: eligible, state: state)
        if batch.isEmpty {
            logger.error("Generated no configurations — the tunnel has nothing to attempt")
        } else {
            logger.info("Generated \(batch.count) configuration(s) across \(eligible.count) server(s)")
        }
        return batch
    }

    /// Builds the connection configurations across the eligible servers, honoring the selected protocol.
    private func configurations(for servers: [Server], state: PIATunnelSharedState.State) -> [any VpnConfiguration] {
        switch state.selectedProtocol {
        case .wireGuard:
            return servers.flatMap { generateWireGuardConfigurations(server: $0, state: state) }
        case .openVPN:
            return servers.flatMap { generateOpenVPNConfigurations(server: $0, state: state) }
        case .automatic:
            // Pecking order per country, built in `PIAEndpointRepository+PeckingOrder.swift`.
            // Transport and port are dictated by the pecking order, not the user's saved OpenVPN settings.
            return automaticConfigurations(servers: servers, state: state, order: peckingOrder(for: state))
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

        // Explains the fan-out size, and whether the ordering means anything at all: with no measured
        // latencies the sort is arbitrary.
        let measured = candidates.filter { state.latencyByServerId[$0.identifier] != nil }.count
        let dropped = servers.count - candidates.count
        if candidates.isEmpty {
            logger.error("Automatic (no selection): no eligible servers — \(servers.count) server(s) all offline or DIP")
        } else {
            logger.info(
                "Automatic (no selection): \(candidates.count) eligible server(s), fastest first — "
                    + "\(dropped) dropped (offline/DIP), \(measured) with measured latency"
            )
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
            logger.info("Dedicated IP target — using the app-provided server list as-is (no fetch)")
            return state.servers
        }

        if let fetchedAt = state.serversFetchedAt,
            Date().timeIntervalSince(fetchedAt) < PIATunnelSharedState.serversCacheTTL,
            !state.servers.isEmpty
        {
            logger.info(
                "Reusing cached server list — \(state.servers.count) server(s), "
                    + "fetched \(Int(Date().timeIntervalSince(fetchedAt)))s ago"
            )
            return state.servers
        }

        if let fetched = await Client.downloadServerList() {
            logger.info("Fetched fresh server list — \(fetched.count) server(s), caching it in shared state")
            PIATunnelSharedState.updateServers(fetched)
            return fetched
        }

        // Not routine — everything downstream now runs off a stale or unverified list, so log its age.
        let age = state.serversFetchedAt.map { "\(Int(Date().timeIntervalSince($0)))s old" } ?? "never fetched"
        logger.warning(
            "Server list fetch failed — falling back to the existing list in shared state "
                + "(\(state.servers.count) server(s), \(age))"
        )
        return state.servers
    }
}
