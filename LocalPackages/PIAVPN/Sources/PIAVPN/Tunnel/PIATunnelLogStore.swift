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

/// Process-wide in-memory ring buffer capturing everything logged via `PIATunnelLogger`.
///
/// `os.Logger` output isn't readable by the app process (only Console.app / `log stream` while
/// attached to the extension), so this is the only way `PIAPacketTunnelRequest.requestLog` can hand
/// the app a snapshot of the tunnel's own log. It only holds what this process instance logged since
/// launch — nothing persists across a tunnel relaunch.
final class PIATunnelLogStore: @unchecked Sendable {
    static let shared = PIATunnelLogStore()

    private let maxEntries = 1000
    private let queue = DispatchQueue(label: "PIATunnelLogStore", attributes: .concurrent)
    private var lines: [String] = []

    private init() {}

    func append(_ line: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            lines.append(line)
            if lines.count > maxEntries {
                lines.removeFirst(lines.count - maxEntries)
            }
        }
    }

    func snapshot() -> String {
        queue.sync {
            lines.joined(separator: "\n")
        }
    }
}
