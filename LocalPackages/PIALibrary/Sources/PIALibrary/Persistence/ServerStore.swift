//
//  ServerStore.swift
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

private let log = PIALogger.logger(for: ServerStore.self)

/// Serializes reads, writes and read-modify-writes of the cached server list, over an in-memory copy.
final class ServerStore: @unchecked Sendable {

    private let mutex = Mutex<Void>(())

    /// `Server` is not `Sendable`, so the copy lives beside the mutex rather than inside it.
    private var cache: [Server]?

    private let load: () -> [Server]
    private let save: ([Server]) -> Void

    /// `load`/`save` are injected so this is testable without an App Group entitlement.
    init(load: @escaping () -> [Server], save: @escaping ([Server]) -> Void) {
        self.load = load
        self.save = save
    }

    func read() -> [Server] {
        return mutex.withLock { _ in
            let servers = readLocked()
            log.debug("Read \(servers.count) server(s), \(dedicatedIPCount(in: servers)) dedicated")
            return servers
        }
    }

    func write(_ servers: [Server]) {
        mutex.withLock { _ in
            log.debug("Writing \(servers.count) server(s), \(dedicatedIPCount(in: servers)) dedicated")
            writeLocked(servers)
        }
    }

    /// Reads, edits and writes back atomically. `body` returns `false` to skip the write.
    ///
    /// - Important: the mutex is not recursive, so `body` must not touch this store.
    @discardableResult func mutate(_ body: (inout [Server]) -> Bool) -> Bool {
        return mutex.withLock { _ in
            var servers = readLocked()
            let countBefore = servers.count
            guard body(&servers) else {
                log.debug("Mutation skipped, keeping \(countBefore) server(s)")
                return false
            }
            log.debug(
                "Mutating \(countBefore) server(s) into \(servers.count), \(dedicatedIPCount(in: servers)) dedicated"
            )
            writeLocked(servers)
            return true
        }
    }

    /// Drops the copy, for when the persisted list is cleared behind this store's back.
    func invalidate() {
        mutex.withLock { _ in
            log.debug("Invalidating the in-memory copy")
            cache = nil
        }
    }

    // MARK: Locked

    private func readLocked() -> [Server] {
        if let cache { return cache }
        let servers = load()
        log.debug("Loaded \(servers.count) server(s) from persistence")
        cache = servers
        return servers
    }

    private func writeLocked(_ servers: [Server]) {
        cache = servers
        save(servers)
        log.debug("Persisted \(servers.count) server(s)")
    }

    private func dedicatedIPCount(in servers: [Server]) -> Int {
        return servers.count { $0.dipToken != nil }
    }
}
