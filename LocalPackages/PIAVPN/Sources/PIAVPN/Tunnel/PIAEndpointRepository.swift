import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

final class PIAEndpointRepository: VpnConfigurationGenerator, Sendable {
    let logger = PIATunnelLogger(label: "PIAEndpointRepository")

    func generateConfigurations() async -> [any VpnConfiguration] {
        let state = PIATunnelSharedState.read()

        guard let server = await resolveSelectedServer(state: state) else {
            logger.error("No server could be resolved — returning no configurations")
            return []
        }

        switch state.selectedProtocol {
        case .wireGuard:
            return generateWireGuardConfigurations(server: server, state: state)
        case .openVPN:
            return generateOpenVPNConfigurations(server: server, state: state)
        }
    }

    /// Resolves the target server, reusing the file-backed cache while it is fresh and otherwise
    /// fetching a new list and persisting it for the next connect.
    ///
    /// Dedicated IP servers are per-user and not served by the public regions list, so for a DIP
    /// target we skip the fetch and resolve directly from the shared-state list (the app ships just
    /// the DIP server there). For a regular target: while `serversFetchedAt` is within the TTL we
    /// reuse `state.servers` without hitting the network; once stale (or never fetched) we fetch a
    /// fresh list, write it back to shared state — so the next process, including on-demand
    /// reconnects with no app running, reuses it — and only fall back to the existing list on
    /// failure.
    private func resolveSelectedServer(state: PIATunnelSharedState.State) async -> Server? {
        if state.selectedDipToken != nil {
            return state.selectedServer(in: state.servers)
        }

        if let fetchedAt = state.serversFetchedAt,
            Date().timeIntervalSince(fetchedAt) < PIATunnelSharedState.serversCacheTTL,
            let server = state.selectedServer(in: state.servers)
        {
            logger.info("Reusing cached server list (fetched \(Int(Date().timeIntervalSince(fetchedAt)))s ago)")
            return server
        }

        if let fetched = await Client.downloadServerList() {
            logger.info("Fetched fresh server list — caching it in shared state")
            PIATunnelSharedState.updateServers(fetched)
            if let server = state.selectedServer(in: fetched) {
                return server
            }
        }

        logger.info("Falling back to the existing server list in shared state")
        return state.selectedServer(in: state.servers)
    }
}
