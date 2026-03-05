//
//  WGPacketTunnelProvider+Connectivity.swift
//  PIAWireguard
//
//  Created by Jose Antonio Blaya Garcia on 26/02/2020.
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

import Foundation
import NetworkExtension
import os.log
import __PIAWireGuardNative

extension WGPacketTunnelProvider {

    // MARK: - Public Entry Point

    /// Starts dead-tunnel detection: a single periodic timer checks RX bytes throughout the
    /// tunnel's lifetime. Once bytes go stale, the pinger is also activated to generate traffic
    /// and the WireGuard handshake timestamp is checked in parallel as an additional liveness
    /// signal. The timer never switches — byte monitoring continues regardless.
    func configureNetworkActivityListener() {
        DispatchQueue.main.async {
            if self.connectivityTimer == nil {
                self.connectivityTimer = Timer.scheduledTimer(
                    withTimeInterval: self.connectivityInterval,
                    repeats: true
                ) { [weak self] _ in
                    self?.checkNetworkActivity()
                }
                self.connectivityTimer?.tolerance = 5
            }
        }
    }

    // MARK: - Connectivity Check

    /// Runs on every timer tick.
    ///
    /// - Bytes changed → traffic is flowing; reset counter and stop pinger if it was running.
    /// - Bytes unchanged, but handshake recent → peer is reachable (idle connection); reset counter,
    ///   stop pinger if it was running.
    /// - Bytes unchanged and handshake stale:
    ///   - First stale tick: start the pinger to generate traffic.
    ///   - After `wireGuardMaxConnectionAttempts` consecutive stale ticks, kill the tunnel so
    ///     the app can trigger a server failover.
    ///
    /// Note: TX bytes are intentionally ignored — WireGuard keeps bumping TX with handshake
    /// initiations even when the server is completely unreachable.
    private func checkNetworkActivity() {
        let currentRxBytes = self.latestWireGuardSettings.rx_bytes

        self.updateSettings()

        let bytesUpdated = currentRxBytes != self.latestWireGuardSettings.rx_bytes
        // Checked on every tick: a recent handshake confirms the peer is reachable at the
        // protocol level even when no application traffic flows (idle connection). Many servers
        // also block ICMP, so pings may never produce RX bytes — the handshake timestamp is a
        // stronger liveness signal than byte counts alone.
        let handshakeRecent = self.latestWireGuardSettings.isHandshakeCompleted()

        if bytesUpdated || handshakeRecent {
            wg_log(.info, message: "Tunnel alive (bytesUpdated=\(bytesUpdated), handshakeRecent=\(handshakeRecent)). Resetting counter")
            wireGuardConnectionAttempts = 0
            pinger?.stop()
        } else {
            if wireGuardConnectionAttempts < wireGuardMaxConnectionAttempts {
                wireGuardConnectionAttempts += 1
                if wireGuardConnectionAttempts == 1 {
                    wg_log(.info, message: "Bytes stale, activating ping checks in parallel")
                    pinger?.start()
                } else {
                    wg_log(.info, message: "Bytes and handshake not updated, retrying in 10 seconds")
                }
            } else {
                wg_log(.info, message: "Max number of attempts to check if the tunnel is alive reached. Stopping the tunnel now")
                wireGuardConnectionAttempts = 0
                cancelTunnelWithError(PacketTunnelProviderError.connectivityCheckFailed)
            }
        }
    }
}
