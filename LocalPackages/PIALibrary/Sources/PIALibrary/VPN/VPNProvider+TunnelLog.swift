//
//  VPNProvider+TunnelLog.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 07.08.26.
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

    // Resolves to nil on error or timeout. The tunnel never replies to the provider message when
    // its process is wedged (e.g. after a network change), so an unguarded bridge would suspend
    // forever; the caller treats a missing log as a non-fatal, reportable condition.
    public func tunnelLog(timeout: TimeInterval = 5) async -> String? {
        // Whichever of the tunnel reply and the timeout arrives first wins. `AsyncStream` is what
        // makes that safe: yielding to a finished continuation is a no-op, whereas resuming a
        // `CheckedContinuation` twice would trap when a slow tunnel replies after the timeout.
        let results = AsyncStream<String?> { continuation in
            requestTunnelLog { log, _ in
                continuation.yield(log)
                continuation.finish()
            }

            Task {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                continuation.yield(nil)
                continuation.finish()
            }
        }

        for await log in results {
            return log
        }

        return nil
    }
}
