//
//  PIACSITunnelLogInformationProvider.swift
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
import PIACSI

struct PIACSITunnelLogInformationProvider: CSIDataProvider {
    static let liveSectionName = "tunnel.log"
    /// Used when the tunnel is down and the log comes from the copy it persisted last.
    static let lastSessionSectionName = "last_tunnel.log"

    var sectionName: String = Self.liveSectionName
    var content: String? { getTunnelLogs() }
    let log: String?
    let includeDebug: Bool
    let redactIPs: Bool

    private func getTunnelLogs() -> String {
        guard let log, !log.isEmpty else {
            return "No tunnel logs available"
        }

        let logs = includeDebug ? log : Self.removingDebugEntries(from: log)
        return redactIPs ? logs.redactIPs() : logs
    }

    /// Drops `TRACE` and `DEBUG` entries, matching `PIALogHandler.getAllLogs(includeDebug:)`. An entry
    /// is a line written by `PIATunnelLogger` as `<timestamp> [<LEVEL>] <label>: <message>`; lines
    /// without that prefix continue a multi-line message and go with the entry they belong to.
    static func removingDebugEntries(from log: String) -> String {
        var isDroppingEntry = false
        return
            log
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { line in
                if let level = entryLevel(of: line) {
                    isDroppingEntry = debugLevels.contains(level)
                }
                return !isDroppingEntry
            }
            .joined(separator: "\n")
    }

    private static let debugLevels: Set<Substring> = ["TRACE", "DEBUG"]

    /// The level of a line that starts an entry, or `nil` for a continuation line.
    private static func entryLevel(of line: Substring) -> Substring? {
        guard let open = line.firstIndex(of: " "),
            line[line.index(after: open)...].hasPrefix("["),
            let close = line[open...].firstIndex(of: "]")
        else {
            return nil
        }
        let level = line[line.index(open, offsetBy: 2)..<close]
        return allLevels.contains(level) ? level : nil
    }

    private static let allLevels: Set<Substring> = ["TRACE", "DEBUG", "INFO", "WARNING", "ERROR"]
}
