//
//  PIAEndpointRepository+Snapshot.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
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

import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

/// Retention of the batch the tunnel is actually working through, so
/// `PIAPacketTunnelRequest.connectionConfigurations` can hand it to the app.
///
/// The SDK keeps no copy to read back: `VpnConfigurationStream.AsyncIterator.pending` is private, is
/// owned by a local iterator inside the session controller's run loop, and is consumed destructively
/// — by the time a connection is up it holds only the endpoints *not* tried, which is the opposite of
/// what the debug menu needs.
///
/// Retained rather than regenerated on demand, because `generateConfigurations()` is not free of side
/// effects: it can fetch the server list over the network, writes that list back to shared state, and
/// re-logs the whole pecking order into the log the debug menu displays. It would also answer "what
/// would we attempt now" rather than "what are we attempting".
extension PIAEndpointRepository {

    /// Generation runs on `KapeSessionController`'s executor while the read arrives on whatever thread
    /// `handleAppMessage` is delivered on. Isolating the one piece of mutable state here keeps
    /// `PIAEndpointRepository` itself `Sendable`, with no manual locking.
    actor LatestBatch {
        private var configurations: [PIAConnectionConfiguration] = []

        func store(_ configurations: [PIAConnectionConfiguration]) {
            self.configurations = configurations
        }

        func current() -> [PIAConnectionConfiguration] {
            configurations
        }
    }

    var latestConfigurations: [PIAConnectionConfiguration] {
        get async { await latestBatch.current() }
    }

    /// Records a batch and prods the app to re-read. Safe to signal from here because that read is a
    /// plain IPC fetch of `latestConfigurations` — it does not generate, so it cannot feed back.
    ///
    /// Maps through the generic `VpnConfiguration` surface, so a protocol PIA wires up later is
    /// captured without touching this; anything opting out of endpoint reporting is dropped.
    func retain(_ batch: [any VpnConfiguration]) async {
        let configurations = batch.compactMap { configuration -> PIAConnectionConfiguration? in
            guard let endpoint = configuration.connectedEndpointSnapshot else {
                return nil
            }

            return PIAConnectionConfiguration(
                vpnProtocol: endpoint.protocolDescription,
                host: endpoint.host,
                port: endpoint.port
            )
        }

        await latestBatch.store(configurations)
        PIATunnelSignal.connectionConfigurationsDidChange.post()
    }
}
