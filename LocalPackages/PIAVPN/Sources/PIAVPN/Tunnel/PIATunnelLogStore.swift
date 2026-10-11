//
//  PIATunnelLogStore.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 09.06.26.
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
import PIALibrary

/// Process-wide ring buffer capturing what is logged via `PIATunnelLogger`.
///
/// `os.Logger` output isn't readable by the app process (only Console.app / `log stream` while
/// attached to the extension), so this is the only way `PIAPacketTunnelRequest.requestLog` can hand
/// the app a snapshot of the tunnel's own log.
///
/// The buffer is also persisted to `PIATunnelSharedState.lastTunnelLogURL()`, so a CSI report sent
/// while the tunnel is down still carries the log of the last session — typically the failed
/// connection the user is reporting. Writes are debounced by `flushDelay` rather than made per line,
/// and `flush()` forces one where the process may be torn down (stop, failed start). A new tunnel
/// process restores the file into its buffer, so an attempt that failed in an earlier process is
/// not overwritten by the next one.
///
/// Every level is mirrored here, `trace` and `debug` included — the SDK reports connection state
/// transitions (OpenVPN status changes, DNS failures, authentication steps) at `debug`, and those are
/// the lines a CSI report needs. `maxEntries` is sized for that: endpoint generation alone can emit
/// several hundred lines per connect when the region is Automatic.
final class PIATunnelLogStore: @unchecked Sendable {
    static let shared = PIATunnelLogStore(fileURL: PIATunnelSharedState.lastTunnelLogURL())

    /// ~5k lines is roughly 750 KB of strings — affordable inside a Network Extension's memory budget,
    /// and enough to hold several connection attempts including their per-candidate detail.
    private let maxEntries: Int
    private let fileURL: URL?
    private let flushDelay: DispatchTimeInterval
    private let queue = DispatchQueue(label: "PIATunnelLogStore", attributes: .concurrent)
    private var lines: [String] = []
    private var isFlushScheduled = false

    /// - Parameter fileURL: where the buffer persists; `nil` keeps it in memory only. Injectable so
    ///   tests don't need the App Group entitlement.
    init(fileURL: URL?, maxEntries: Int = 5000, flushDelay: DispatchTimeInterval = .seconds(2)) {
        self.fileURL = fileURL
        self.maxEntries = maxEntries
        self.flushDelay = flushDelay
        lines = Self.restoredLines(from: fileURL, maxEntries: maxEntries)
    }

    func append(_ line: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            appendLocked(line)
            scheduleFlushLocked()
        }
    }

    func snapshot() -> String {
        queue.sync {
            lines.joined(separator: "\n")
        }
    }

    /// Persists the buffer now, after any pending `append`. Call it where the process may be torn
    /// down before the debounced write fires.
    func flush() {
        queue.sync(flags: .barrier) {
            writeLocked()
        }
    }

    // MARK: Guarded by `queue`

    private func appendLocked(_ line: String) {
        lines.append(line)
        if lines.count > maxEntries {
            lines.removeFirst(lines.count - maxEntries)
        }
    }

    private func scheduleFlushLocked() {
        guard fileURL != nil, !isFlushScheduled else { return }
        isFlushScheduled = true
        queue.asyncAfter(deadline: .now() + flushDelay, flags: .barrier) { [weak self] in
            guard let self else { return }
            isFlushScheduled = false
            writeLocked()
        }
    }

    private func writeLocked() {
        guard let fileURL else { return }
        // Not logged on failure: the logger writes into this store, so it would only recurse. A missed
        // write costs a CSI report its fallback log, nothing more.
        try? Data(lines.joined(separator: "\n").utf8).write(to: fileURL, options: .atomic)
    }

    /// The persisted log's newest lines, followed by a marker so a reader can tell where this process
    /// took over. Empty when there is nothing to restore.
    private static func restoredLines(from fileURL: URL?, maxEntries: Int) -> [String] {
        guard let fileURL,
            let content = try? String(contentsOf: fileURL, encoding: .utf8),
            !content.isEmpty
        else {
            return []
        }

        let marker =
            "\(ISO8601DateFormatter().string(from: Date())) [INFO] PIATunnelLogStore: "
            + "new tunnel process; lines above are restored from the previous one"
        let restored = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        return Array(restored.suffix(maxEntries - 1)) + [marker]
    }
}
