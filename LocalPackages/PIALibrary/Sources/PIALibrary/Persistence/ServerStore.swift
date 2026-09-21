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

/// Owns the cached server list: an in-memory copy over a persisted one.
///
/// ``mutate(_:)`` holds the mutex across the whole read-modify-write, so two writers cannot build on
/// a snapshot the other has already superseded. The list is refreshed from the network off the main
/// thread while the UI reads it, and a dedicated IP is appended from the main thread, so an
/// unsynchronized `append` used to lose whichever update landed second.
///
/// Mirrors `PIATunnelSharedState.Store`, which solves the same problem for the tunnel's shared state.
final class ServerStore: @unchecked Sendable {

    /// Guards `cache` and the `load`/`save` pair.
    private let mutex = Mutex<Void>(())

    /// The loaded list, or `nil` before the first read. `Server` is not `Sendable`, so it lives
    /// beside the mutex rather than inside it.
    private var cache: [Server]?

    private let load: () -> [Server]
    private let save: ([Server]) -> Void

    /// - Parameters:
    ///   - load: Reads the persisted list. Injectable so the read-modify-write is testable without
    ///     an App Group entitlement, which a unit-test process does not have.
    ///   - save: Persists the list.
    init(load: @escaping () -> [Server], save: @escaping ([Server]) -> Void) {
        self.load = load
        self.save = save
    }

    /// The cached list, loading it from persistence on the first read.
    func read() -> [Server] {
        return mutex.withLock { _ in readLocked() }
    }

    /// Replaces the list wholesale.
    func write(_ servers: [Server]) {
        mutex.withLock { _ in writeLocked(servers) }
    }

    /// Reads, edits and writes back under the mutex, so no concurrent mutation is lost. `body`
    /// returns `false` to skip the write, keeping an "only if changed" test atomic with the write it
    /// guards.
    ///
    /// - Important: the mutex is not recursive, so `body` must not touch this store.
    /// - Returns: whether `body` asked for the write.
    @discardableResult func mutate(_ body: (inout [Server]) -> Bool) -> Bool {
        return mutex.withLock { _ in
            var servers = readLocked()
            guard body(&servers) else {
                return false
            }

            writeLocked(servers)
            return true
        }
    }

    /// Drops the in-memory copy, so the next read goes back to persistence. For when the persisted
    /// list is cleared behind this store's back.
    func invalidate() {
        mutex.withLock { _ in cache = nil }
    }

    // MARK: Locked

    private func readLocked() -> [Server] {
        if let cache {
            return cache
        }

        let servers = load()
        cache = servers
        return servers
    }

    private func writeLocked(_ servers: [Server]) {
        cache = servers
        save(servers)
    }
}
