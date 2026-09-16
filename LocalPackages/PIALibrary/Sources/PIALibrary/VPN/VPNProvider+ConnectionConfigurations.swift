//
//  VPNProvider+ConnectionConfigurations.swift
//  PIALibrary
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

extension VPNProvider {

    /// The endpoints the tunnel will attempt, in attempt order — Automatic's pecking order, or the
    /// pinned protocol's fan-out. Answered by the extension process, so it is empty whenever that
    /// process isn't running (i.e. while disconnected).
    ///
    /// Not a `VPNProvider` requirement: it is specific to the PlatformSDK tunnel, so it resolves
    /// that profile directly rather than going through `activeProfile` and forcing every legacy
    /// profile to implement it.
    ///
    /// Resolves to an empty list on error or timeout, for the same reason as `tunnelLog()`: the
    /// tunnel never replies to the provider message when its process is wedged, so an unguarded
    /// bridge would suspend forever.
    public func connectionConfigurations(timeout: TimeInterval = 5) async -> [PIAConnectionConfiguration] {
        guard let profile = Client.configuration.profile(forVPNType: KapePlatformSDKTunnelProfile.vpnType) as? KapePlatformSDKTunnelProfile else {
            return []
        }

        // Whichever of the tunnel reply and the timeout arrives first wins. `AsyncStream` is what
        // makes that safe: yielding to a finished continuation is a no-op, whereas resuming a
        // `CheckedContinuation` twice would trap when a slow tunnel replies after the timeout.
        let results = AsyncStream<[PIAConnectionConfiguration]> { continuation in
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                continuation.yield([])
                continuation.finish()
            }

            // Installed before the request is sent, so a reply can never finish the stream while the
            // timer is still sleeping out its full interval for nothing.
            continuation.onTermination = { _ in timeoutTask.cancel() }

            profile.requestConnectionConfigurations { configurations, _ in
                continuation.yield(configurations ?? [])
                continuation.finish()
            }
        }

        for await configurations in results {
            return configurations
        }

        return []
    }
}
