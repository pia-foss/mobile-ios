//
//  PIATunnelLogger.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 10.06.26.
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
import os

/// Tunnel-side logger that writes to Apple's unified logging system.
///
/// `print()` is invisible inside a Network Extension — there is no stdout to
/// attach to. `os.Logger` routes to the unified log, which you can read live
/// while hooked into the tunnel process via Console.app or:
///
///     log stream --predicate 'subsystem CONTAINS "PlatformSDK-Tunnel"' --level debug
///
/// The subsystem is the extension's own bundle id (e.g.
/// `…PIA-VPN.PlatformSDK-Tunnel-iOS`, or `…dev.PIA-VPN.…` on Development), so the
/// `CONTAINS` predicate matches every build configuration and both platforms.
/// Each logger instance uses its `label` as the os_log category, so you can
/// further filter by category in Console.app.
///
/// Note: `os.Logger` redacts interpolated values as `<private>` by default.
/// The message is already a fully-formed `String` here, so it is logged with
/// `privacy: .public` to keep it readable.
final class PIATunnelLogger: PacketTunnelLogger, Sendable {
    private let log: Logger
    private let label: String
    private static let dateFormatter = ISO8601DateFormatter()

    init(label: String) {
        self.log = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "PlatformSDK-Tunnel",
            category: label
        )
        self.label = label
    }

    func trace(_ message: @autoclosure () -> String) {
        // Bound first: `os.Logger`'s interpolation is an escaping autoclosure.
        let message = message()
        log.trace("\(message, privacy: .public)")
        store("TRACE", message)
    }

    func debug(_ message: @autoclosure () -> String) {
        let message = message()
        log.debug("\(message, privacy: .public)")
        store("DEBUG", message)
    }

    func info(_ message: @autoclosure () -> String) {
        let message = message()
        log.info("\(message, privacy: .public)")
        store("INFO", message)
    }

    func warning(_ message: @autoclosure () -> String) {
        let message = message()
        log.warning("\(message, privacy: .public)")
        store("WARNING", message)
    }

    func error(_ message: @autoclosure () -> String) {
        let message = message()
        log.error("\(message, privacy: .public)")
        store("ERROR", message)
    }

    /// Mirrors the line into `PIATunnelLogStore` so `PIAPacketTunnelRequest.requestLog` can hand it
    /// back to the app — `os.Logger` above is not readable cross-process.
    private func store(_ level: String, _ message: String) {
        let timestamp = Self.dateFormatter.string(from: Date())
        PIATunnelLogStore.shared.append("\(timestamp) [\(level)] \(label): \(message)")
    }
}
