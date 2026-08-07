//
//  ServersPinger.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Algorithms
import Foundation

private let log = PIALogger.logger(for: ServersPinger.self)

/// Outcome of a `ServersPinger.ping(withDestinations:)` pass.
public enum PingServersResult: Sendable, Equatable {
    /// Pings finished, results were serialized and `.PIADaemonsDidPingServers` was posted.
    case completed
    /// Nothing was pinged because the VPN is not disconnected.
    case skippedVPNActive
    /// The pass was interrupted by `reset()`.
    case cancelled
}

internal actor ServersPinger: DatabaseAccess {
    static let shared = ServersPinger()

    private static let pingTimeout: TimeInterval = 3
    private static let maxConcurrentPings = 16

    private let pinger: Pinger
    private var inflightTask: Task<PingServersResult, Never>?

    init(pinger: Pinger = TCPPinger.shared) {
        self.pinger = pinger
    }

    func ping(withDestinations destinations: [Server]) async -> PingServersResult {
        // Join an in-flight pass instead of skipping, so every caller gets a result.
        if let inflightTask {
            log.debug("Ping already in flight, joining it")
            return await inflightTask.value
        }

        guard accessedDatabase.transient.vpnStatus == .disconnected else {
            log.debug("Not pinging servers while on VPN, will try on next update")
            return .skippedVPNActive
        }

        accessedDatabase.plain.clearPings()

        let task = Task { () -> PingServersResult in
            await self.runPingPass(destinations)
            log.debug("Finished pinging servers")

            // A cancelled pass must not clear the slot (reset() already did, and a new
            // pass may own it), nor serialize half-baked pings or post the notification.
            if Task.isCancelled { return .cancelled }

            self.inflightTask = nil
            self.mirrorLatenciesToPlatformSDK(destinations)
            self.finish()
            return .completed
        }
        inflightTask = task
        return await task.value
    }

    func reset() {
        inflightTask?.cancel()
        inflightTask = nil
    }

    private func runPingPass(_ destinations: [Server]) async {
        for destinations in destinations.chunks(ofCount: Self.maxConcurrentPings) {
            if Task.isCancelled { break }
            await withTaskGroup(of: Void.self) { group in
                for server in destinations {
                    log.debug("Pinging \(server.identifier)")
                    for address in server.addresses() {
                        group.addTask {
                            await self.pingServer(server, address: address)
                        }
                    }
                }
            }
        }
    }

    // Mirror the freshly measured latencies into the PlatformSDK shared state so the tunnel
    // extension can pick the fastest server in its app-less fallback (see
    // `PIATunnelSharedState.State.selectedServer(in:)`). The `servers` list it carries cannot
    // hold this — `Server`'s Codable form drops `responseTime`. Keyed by `Server.identifier`;
    // a DIP server shares its identifier with its base region but resolves to the same latency.
    private func mirrorLatenciesToPlatformSDK(_ destinations: [Server]) {
        let latencies = Dictionary(
            destinations.compactMap { server in
                accessedDatabase.plain.ping(forServerIdentifier: server.identifier).map { (server.identifier, $0) }
            },
            uniquingKeysWith: min
        )
        PIATunnelSharedState.updateLatencies(latencies)
    }

    private func pingServer(_ server: Server, address: Server.ServerAddressIP) async {
        log.debug("Starting to Ping \(server.identifier) with address: \(address.ip)")

        guard let responseTime = await pinger.ping(ip: address.ip, port: 443, timeout: Self.pingTimeout) else {
            log.warning("Timeout/error for \(server.identifier)")
            return
        }

        // Discards results where VPN connected during the ping.
        guard accessedDatabase.transient.vpnStatus == .disconnected else {
            log.warning("Discarded VPN-biased response from \(server.identifier): \(responseTime)")
            return
        }

        log.debug("Response time from \(server.identifier): \(responseTime)")
        server.updateResponseTime(responseTime, forAddress: address)
        accessedDatabase.plain.setPing(responseTime, forServerIdentifier: server.identifier)
    }

    private func finish() {
        accessedDatabase.plain.serializePings()

        Task { @MainActor in
            Macros.postNotification(.PIADaemonsDidPingServers)
        }
    }
}
